Yes! 💜 Her er en 1:1 port af LÖVR-eksemplet til **Heaps + HXSL + OpenGL**.

Vi laver:

* `SDFLinkShader.hx` – HXSL raymarch-shader (samme SDF scene)
* `Main.hx` – lille Heaps-app der kører den som fullscreen postprocess (`ScreenFx`)

---

## `SDFLinkShader.hx`

```haxe
package;

import h3d.shader.ScreenShader;

class SDFLinkShader extends ScreenShader {
  static var SRC = {

    @param var time : Float;
    @param var resolution : Vec2; // (width, height) fra Heaps

    // ScreenShader giver os:
    // var calculatedUV : Vec2;
    // var output : { var color : Vec4; }

    // ---------- Helpers ----------

    function sdBox(p:Vec3, b:Vec3):Float {
      var q = abs(p) - b;
      return length(max(q, vec3(0.0, 0.0, 0.0)))
           + min(max(q.x, max(q.y, q.z)), 0.0);
    }

    function sdCapsule(p:Vec3, a:Vec3, b:Vec3, r:Float):Float {
      var pa = p - a;
      var ba = b - a;
      var h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
      return length(pa - ba * h) - r;
    }

    // egen smoothstep (i stedet for builtin, for sikkerhed)
    function smoothStep(edge0:Float, edge1:Float, x:Float):Float {
      var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
      return t * t * (3.0 - 2.0 * t);
    }

    // Smooth union – “organisk” overgang
    function opSmoothUnion(d1:Float, d2:Float, k:Float):Float {
      var h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
      return mix(d2, d1, h) - k * h * (1.0 - h);
    }

    // ---------- SDF scene: 2 hard surfaces + organisk link ----------

    function map(p:Vec3):Float {
      // lidt “puls” i Y
      p.y += sin(time * 0.5) * 0.1;

      // to hårde bokse
      var p1 = p - vec3(-0.9, 0.0, 0.0);
      var p2 = p - vec3( 0.9, 0.0, 0.0);

      var box1 = sdBox(p1, vec3(0.5, 0.3, 0.4));
      var box2 = sdBox(p2, vec3(0.5, 0.3, 0.4));

      // organisk link (capsule mellem indersider)
      var a = vec3(-0.4, 0.0, 0.0);
      var b = vec3( 0.4, 0.0, 0.0);
      var link = sdCapsule(p, a, b, 0.2);

      var hard = min(box1, box2);
      var res  = opSmoothUnion(hard, link, 0.25);

      return res;
    }

    // ---------- Normal, lighting, raymarch ----------

    function calcNormal(p:Vec3):Vec3 {
      var e = vec2(0.001, 0.0);

      var dx = map(p + vec3(e.x, e.y, e.y)) - map(p - vec3(e.x, e.y, e.y));
      var dy = map(p + vec3(e.y, e.x, e.y)) - map(p - vec3(e.y, e.x, e.y));
      var dz = map(p + vec3(e.y, e.y, e.x)) - map(p - vec3(e.y, e.y, e.x));

      return normalize(vec3(dx, dy, dz));
    }

    // Returnerer (p.xyz, tHit) – hvis no hit: w = -1
    function raymarch(ro:Vec3, rd:Vec3):Vec4 {
      var t = 0.0;
      var p = ro;

      for (i in 0...128) {
        p = ro + rd * t;
        var d = map(p);
        if (d < 0.0005) {
          return vec4(p.x, p.y, p.z, t);
        }
        t += d;
        if (t > 20.0) break;
      }

      return vec4(p.x, p.y, p.z, -1.0);
    }

    function shade(p:Vec3, rd:Vec3):Vec3 {
      var n = calcNormal(p);

      var lightDir = normalize(vec3(0.6, 0.8, -0.4));
      var diff = max(dot(n, lightDir), 0.0);

      var rim = pow(1.0 - max(dot(n, -rd), 0.0), 2.0);

      // heuristik: organisk midt imellem boksene
      var linkMask = smoothStep(0.4, 0.0, abs(p.x));
      var hardColor    = vec3(0.3, 0.35, 0.4);
      var organicColor = vec3(0.8, 0.4, 0.2);
      var baseColor = mix(hardColor, organicColor, linkMask);

      var col = baseColor * (0.15 + 0.85 * diff);
      col += rim * vec3(0.6, 0.7, 1.0);
      col += vec3(0.05, 0.06, 0.07); // ambient

      return col;
    }

    // ---------- Fragment ----------

    function fragment() {
      // calculatedUV kommer fra ScreenShader: [0..1]
      var uv = calculatedUV * 2.0 - 1.0;
      uv.x *= resolution.x / resolution.y; // samme aspect-fix som i LÖVR

      var ro = vec3(0.0, 0.0, 4.0);
      var rd = normalize(vec3(uv.x, uv.y, -1.8));

      var rm  = raymarch(ro, rd);
      var p   = rm.xyz;
      var tHit = rm.w;

      var col:Vec3;
      if (tHit > 0.0) {
        col = shade(p, rd);
      } else {
        // baggrund
        var v = 0.15 + 0.1 * uv.y;
        col = vec3(v, v * 1.1, v * 1.3);
      }

      output.color = vec4(col, 1.0);
    }
  }
}
```

---

## `Main.hx`

Minimal Heaps-app der kører shaderen som fullscreen pass med OpenGL-backend (HL+SDL eller C+++GL):

```haxe
package;

import hxd.App;
import h3d.pass.ScreenFx;

class Main extends App {

  var fx  : ScreenFx;
  var sdf : SDFLinkShader;
  var t   : Float = 0.0;

  static function main() {
    new Main();
  }

  override function init() {
    // vores SDF-raymarch shader
    sdf = new SDFLinkShader();
    fx  = new ScreenFx(sdf);
  }

  override function update(dt:Float) {
    t += dt;
  }

  override function render(e:h3d.Engine) {
    // opdater uniforms
    sdf.time = t;
    sdf.resolution.set(e.width, e.height);

    // clear + kør fullscreen shader
    e.clear(0, 0, 0, 1);
    fx.render();
  }
}
```

---

### Helt kort:

* **SDF-scene, raymarch, lighting, organisk link** → 1:1 samme matematik som LÖVR-versionen.
* Vi bruger `ScreenShader` + `ScreenFx`, så fragmenten svarer til LÖVR’s fullscreen plane + `gl_FragCoord`.
* Du får det samme look i Heaps/OpenGL, men nu med Haxe/HXSL-pipeline ovenpå 💫

Hvis du vil, kan vi næste trin gøre det *AxiumForge-agtigt* (pakke `map()` op i moduler, dele hard/organic parts i separate HXSL-“effects”, osv.).
