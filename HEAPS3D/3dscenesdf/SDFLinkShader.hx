package;

import h3d.shader.ScreenShader;

class SDFLinkShader extends ScreenShader {
  static var SRC = {

    @param var time : Float;
    @param var resolution : Vec2; // (width, height) fra Heaps
    @param var cameraPos : Vec3;
    @param var cameraForward : Vec3;
    @param var cameraRight : Vec3;
    @param var cameraUp : Vec3;

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

    // Smooth union that also blends color between the two signed distances
    function opSmoothUnionColor(d1:Float, c1:Vec3, d2:Float, c2:Vec3, k:Float):Vec4 {
      var h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
      var dist = mix(d2, d1, h) - k * h * (1.0 - h);
      var col = mix(c2, c1, h);
      return vec4(dist, col.x, col.y, col.z);
    }

    // ---------- SDF scene: 2 hard surfaces + organisk link ----------

    // Returnerer (distance, color.rgb)
    function map(p:Vec3):Vec4 {
      // lidt “puls” i Y
      p.y += sin(time * 0.5) * 0.1;

      // to hårde bokse
      var p1 = p - vec3(-0.9, 0.0, 0.0);
      var p2 = p - vec3( 0.9, 0.0, 0.0);

      var box1 = sdBox(p1, vec3(0.5, 0.3, 0.4));
      var box2 = sdBox(p2, vec3(0.5, 0.3, 0.4));
      var colBox1 = vec3(0.25, 0.35, 0.55);
      var colBox2 = vec3(0.35, 0.45, 0.3);

      // organisk link (capsule mellem indersider)
      var a = vec3(-0.4, 0.0, 0.0);
      var b = vec3( 0.4, 0.0, 0.0);
      var link = sdCapsule(p, a, b, 0.2);
      var colLink = vec3(0.85, 0.4, 0.2);

      var hard = box1;
      var hardColor = colBox1;
      if (box2 < box1) {
        hard = box2;
        hardColor = colBox2;
      }

      var res = opSmoothUnionColor(hard, hardColor, link, colLink, 0.25);

      return res;
    }

    // ---------- Normal, lighting, raymarch ----------

    function calcNormal(p:Vec3):Vec3 {
      var e = vec2(0.001, 0.0);

      var dx = map(p + vec3(e.x, e.y, e.y)).x - map(p - vec3(e.x, e.y, e.y)).x;
      var dy = map(p + vec3(e.y, e.x, e.y)).x - map(p - vec3(e.y, e.x, e.y)).x;
      var dz = map(p + vec3(e.y, e.y, e.x)).x - map(p - vec3(e.y, e.y, e.x)).x;

      return normalize(vec3(dx, dy, dz));
    }

    // Returnerer (p.xyz, tHit) – hvis no hit: w = -1
    function raymarch(ro:Vec3, rd:Vec3):Vec4 {
      var t = 0.0;
      var p = ro;
      var tHit = -1.0;

      for (i in 0...128) {
        p = ro + rd * t;
        var d = map(p).x;
        if (d < 0.0005) {
          tHit = t;
          break;
        }
        t += d;
        if (t > 20.0) break;
      }

      if (tHit < 0.0) {
        // keep last marched position for background shading
        p = ro + rd * t;
      }

      return vec4(p.x, p.y, p.z, tHit);
    }

    function shade(p:Vec3, rd:Vec3):Vec3 {
      var n = calcNormal(p);
      var scene = map(p);

      var lightDir = normalize(vec3(0.6, 0.8, -0.4));
      var diff = max(dot(n, lightDir), 0.0);

      var rim = pow(1.0 - max(dot(n, -rd), 0.0), 2.0);

      var baseColor = scene.yzw;

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

      var ro = cameraPos;
      var rd = normalize(cameraForward + uv.x * cameraRight + uv.y * cameraUp);

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
