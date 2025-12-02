Kort version:
I Heaps “viser” du 2D SDF ved at:
	1.	Tegne et helt almindeligt rektangel (Bitmap/Mesh) på skærmen.
	2.	Sætte en custom HXSL-shader på, som inde i fragment() selv beregner en distance-funktion og laver alpha fra den.

Her er et helt konkret, kørbart skelet med en SDF-cirkel.

⸻

1. Lav en SDF-shader (Haxe-fil)

shader/SdfCircleShader.hx:

package shader;

class SdfCircleShader extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d; // giver calculatedUV, pixelColor, time, osv.  [oai_citation:0‡heaps.io](https://heaps.io/documentation/h2d-shaders.html)

        // uniforms du kan ændre fra Haxe
        @param var radius : Float;        // 0..1 i UV-rum
        @param var color  : Vec3;         // RGB 0..1
        @param var border : Float;        // blød kant (anti-alias)

        // fragment shader
        function fragment() {
            // UV 0..1 -> -1..1 (center i (0,0))
            var p = calculatedUV * 2.0 - 1.0;

            // signed distance til cirkel
            // d < 0 = inde i cirkel, d = 0 = kant, d > 0 = udenfor
            var d = length(p) - radius;

            // glidende overgang omkring kanten
            var alpha = smoothstep(border, 0.0, d);

            // farve med alpha (ingen texture, ren SDF)
            pixelColor = vec4(color, alpha);
        }
    }
}

Pointen:
	•	calculatedUV kommer fra Base2d og er 0..1 over hele bitmap’et.  ￼
	•	Vi mapper til -1..1, laver en distancefunktion (length(p) - radius) og bruger smoothstep til at lave en blød kant.

⸻

2. Brug shaderen på et 2D-objekt

Main.hx:

import hxd.App;
import h2d.Bitmap;
import h2d.Tile;
import shader.SdfCircleShader;
import h3d.Vector; // til farve

class Main extends App {
    override function init() {
        super.init();

        // 1x1 hvid tile, skaleret op = “lærred” til SDF
        var tile = Tile.fromColor(0xFFFFFFFF, 512, 512);
        var bmp  = new Bitmap(tile, s2d);

        // centrer i skærmen
        bmp.x = (s2d.width  - bmp.width)  * 0.5;
        bmp.y = (s2d.height - bmp.height) * 0.5;

        // opret og konfigurer SDF-shader
        var sdf = new SdfCircleShader();
        sdf.radius = 0.6;                // cirkelstørrelse i UV-rum
        sdf.border = 0.02;               // kantblødhed
        sdf.color  = new Vector(1, 1, 1); // hvid cirkel

        // sæt shader på bitmap
        bmp.addShader(sdf);
    }

    static function main() {
        new Main();
    }
}

Det er det hele: nu får du en ren SDF-cirkel tegnet af GPU’en uden teksturer.

⸻

3. Udvid til flere 2D SDF-former

Når det kører, kan du i shaderen bygge videre:
	•	Box / rounded box

function sdBox(p:Vec2, b:Vec2):Float {
    var d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

	•	Smooth union (to SDF-objekter)

function opSmoothUnion(d1:Float, d2:Float, k:Float):Float {
    var h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

Så kan du inde i fragment() lave fx:

var p = calculatedUV * 2.0 - 1.0;
var d1 = length(p) - radius;             // cirkel
var d2 = sdBox(p - vec2(0.3,0.0), vec2(0.3,0.2)); // box
var d  = opSmoothUnion(d1, d2, 0.1);     // smooth union
var alpha = smoothstep(border, 0.0, d);
pixelColor = vec4(color, alpha);


⸻

Hvis du vil, kan jeg i næste svar lave en “SdfShapesShader” med cirkel + box + smooth union og et lille interface på Haxe-siden (f.eks. enum der vælger shape).