Ja, 100% – det du kalder et “3D SDF plane” er faktisk præcis det man normalt gør, når man raymarcher 3D SDF ind i et 2D billede:
	•	Du har et 2D plane (fullscreen quad / bitmap i Heaps).
	•	På hver pixel skyder shaderen en 3D‐ray ud i et imaginært 3D‐rum.
	•	Den raymarcher i en 3D SDF(map), og farver pixel’en efter det den rammer.

Det hele sker i én HXSL‐shader på et 2D‐objekt – Heaps behøver ikke “rigtig 3D” for at vise det.

⸻

To måder at tænke det på
	1.	Fuld 3D raymarching på et 2D plane
	•	2D calculatedUV → laves om til en 3D ray‐direction.
	•	Vi har en map(p:Vec3):Float som er din 3D SDF‐scene.
	•	Raymarch‐loop inde i fragment().
	2.	3D SDF som 2D “skive” (slice)
	•	Du har stadig en 3D map(p:Vec3).
	•	Men du låser fx p.z = 0 (eller en anden konstant/rotation).
	•	Så du bruger kun ét plan igennem 3D SDF’en, som bliver til et 2D SDF‐billede.

Begge dele kan køre på et helt almindeligt h2d.Bitmap med en custom shader.

⸻

1) Eksempel: 3D SDF raymarch på et 2D plane

Her er et minimalt skelet til en Sdf3DPlaneShader der maler en 3D SDF‐kugle via raymarch:

shader/Sdf3DPlaneShader.hx:

package shader;

class Sdf3DPlaneShader extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d; // giver calculatedUV, pixelColor, osv.

        @param var camPos    : Vec3;   // kamera-position i 3D
        @param var maxDist   : Float;  // max ray afstand
        @param var eps       : Float;  // hit-tolerance
        @param var aspect    : Float;  // screen width / height
        @param var lightDir  : Vec3;   // lysretning
        @param var baseColor : Vec3;   // objektets farve

        // 3D SDF scene: en kugle + et gulv
        function map(p:Vec3):Float {
            var sphere = length(p - vec3(0.0, 0.0, 3.0)) - 1.0;
            var floor  = p.y + 1.0; // plane y = -1
            return min(sphere, floor);
        }

        // normal-approx med central difference
        function calcNormal(p:Vec3):Vec3 {
            var e  = 0.001;
            var dx = vec3(e, 0.0, 0.0);
            var dy = vec3(0.0, e, 0.0);
            var dz = vec3(0.0, 0.0, e);

            var nx = map(p + dx) - map(p - dx);
            var ny = map(p + dy) - map(p - dy);
            var nz = map(p + dz) - map(p - dz);

            return normalize(vec3(nx, ny, nz));
        }

        function fragment() {
            // 0..1 -> -1..1, og ret aspect på x
            var uv = calculatedUV * 2.0 - 1.0;
            uv.x *= aspect;

            // kamera-ray (simpelt: kamera i camPos kigger mod +z)
            var ro = camPos;
            var rd = normalize(vec3(uv.x, uv.y, 1.0));

            var t = 0.0;
            var d = 0.0;
            var hit = false;

            // fast antal steps for compileren
            for (i in 0...128) {
                var p = ro + rd * t;
                d = map(p);
                if (d < eps) {
                    hit = true;
                    break;
                }
                t += d;
                if (t > maxDist) break;
            }

            if (!hit) {
                // baggrund
                pixelColor = vec4(0.0, 0.0, 0.0, 1.0);
                return;
            }

            // shading
            var pos = ro + rd * t;
            var n   = calcNormal(pos);
            var l   = normalize(lightDir);

            var diff = max(dot(n, l), 0.0);
            var col  = baseColor * diff;

            pixelColor = vec4(col, 1.0);
        }
    }
}

Og så bruger du den i 2D som før:

import hxd.App;
import h2d.Bitmap;
import h2d.Tile;
import h3d.Vector;
import shader.Sdf3DPlaneShader;

class Main extends App {
    override function init() {
        super.init();

        var tile = Tile.fromColor(0xFFFFFFFF, s2d.width, s2d.height);
        var bmp  = new Bitmap(tile, s2d);

        var sdf = new Sdf3DPlaneShader();
        sdf.camPos    = new Vector(0, 0, -3);          // kamera foran scenen
        sdf.maxDist   = 20.0;
        sdf.eps       = 0.001;
        sdf.aspect    = s2d.width / s2d.height;
        sdf.lightDir  = new Vector(0.5, 0.8, -0.2);
        sdf.baseColor = new Vector(1, 1, 1);

        bmp.addShader(sdf);
    }

    static function main() {
        new Main();
    }
}

Det er i praksis LÖVR/LÖVE raymarching portet ind i Heaps, bare pakket ind i en 2D‐bitmap.

⸻

2) Eksempel: “3D SDF slice” på et plane

Hvis du i stedet vil bruge 3D SDF som en ren 2D slice, kan du gøre:

function map2D(p2:Vec2):Float {
    // vi embedder 2D i 3D som z=0
    var p3 = vec3(p2.x, p2.y, 0.0);
    return map(p3); // genbrug 3D SDF-funktion
}

function fragment() {
    var p = calculatedUV * 2.0 - 1.0;
    var d = map2D(p);

    var border = 0.01;
    var alpha = smoothstep(border, 0.0, d);

    pixelColor = vec4(baseColor, alpha);
}

Her:
	•	Din scene er stadig defineret som 3D SDF (map(p:Vec3)),
	•	Men du “skærer” en skive igennem (fx z = 0) og får automatisk et 2D SDF billede.

⸻

Hvad giver det dig ift. ren 2D SDF?
	•	3D‐versionen (raymarch) er tungere pr. pixel, men du får:
	•	dybde, lys, skygger, glatte overgange
	•	“organiske” former og boolean kombinationer i 3D
	•	2D slice‐versionen er billigere men stadig:
	•	én “master” 3D SDF du kan bruge både til 3D og 2D visuelt
	•	rotationer af planet = forskellige udsnit = variation gratis

⸻

Hvis du vil, kan jeg næste gang:
	•	Lave en fælles SDF “map” du kan dele mellem LÖVR (3D) og Heaps (2D plane), så du bogstaveligt talt genbruger samme 3D SDF kode/logik til begge.