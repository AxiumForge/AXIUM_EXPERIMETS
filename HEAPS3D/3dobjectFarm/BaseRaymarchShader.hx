package;

import h3d.shader.ScreenShader;

class BaseRaymarchShader extends ScreenShader {
  static var SRC = {

    @param var time : Float;
    @param var resolution : Vec2;
    @param var cameraPos : Vec3;
    @param var cameraForward : Vec3;
    @param var cameraRight : Vec3;
    @param var cameraUp : Vec3;

    // Helper functions
    function rotateXYZ(p:Vec3, r:Vec3):Vec3 {
      var cx = cos(r.x); var sx = sin(r.x);
      var cy = cos(r.y); var sy = sin(r.y);
      var cz = cos(r.z); var sz = sin(r.z);

      var rx = p;
      rx = vec3(rx.x, rx.y * cx - rx.z * sx, rx.y * sx + rx.z * cx);
      rx = vec3(rx.x * cy + rx.z * sy, rx.y, -rx.x * sy + rx.z * cy);
      rx = vec3(rx.x * cz - rx.y * sz, rx.x * sz + rx.y * cz, rx.z);
      return rx;
    }

    // Override this in shape-specific shaders
    // Returns vec4(distance, color.rgb)
    function map(p:Vec3):Vec4 {
      // Default: sphere
      var dist = length(p) - 0.5;
      var col = vec3(0.5, 0.5, 0.5);
      return vec4(dist, col.x, col.y, col.z);
    }

    function calcNormal(p:Vec3):Vec3 {
      var e = vec2(0.001, 0.0);
      var dx = map(p + vec3(e.x, e.y, e.y)).x - map(p - vec3(e.x, e.y, e.y)).x;
      var dy = map(p + vec3(e.y, e.x, e.y)).x - map(p - vec3(e.y, e.x, e.y)).x;
      var dz = map(p + vec3(e.y, e.y, e.x)).x - map(p - vec3(e.y, e.y, e.x)).x;
      return normalize(vec3(dx, dy, dz));
    }

    function raymarch(ro:Vec3, rd:Vec3):Vec4 {
      var t = 0.0;
      var p = ro;
      var tHit = -1.0;

      for (i in 0...160) {
        p = ro + rd * t;
        var d = map(p).x;
        if (d < 0.0008) {
          tHit = t;
          break;
        }
        t += d;
        if (t > 30.0) break;
      }

      if (tHit < 0.0) {
        p = ro + rd * t;
      }

      return vec4(p.x, p.y, p.z, tHit);
    }

    function shade(p:Vec3, rd:Vec3):Vec3 {
      var scene = map(p);
      var n = calcNormal(p);

      var lightDir = normalize(vec3(0.6, 1.2, -0.7));
      var diff = max(dot(n, lightDir), 0.0);
      var rim = pow(1.0 - max(dot(n, -rd), 0.0), 2.2);

      var baseColor = scene.yzw;
      var col = baseColor * (0.2 + 0.8 * diff);
      col += rim * vec3(0.6, 0.8, 1.0);
      col += vec3(0.05, 0.06, 0.07);
      return col;
    }

    function fragment() {
      var uv = calculatedUV * 2.0 - 1.0;
      uv.x *= resolution.x / resolution.y;

      var ro = cameraPos;
      var rd = normalize(cameraForward + uv.x * cameraRight + uv.y * cameraUp);

      var rm = raymarch(ro, rd);
      var p = rm.xyz;
      var tHit = rm.w;

      var col:Vec3;
      if (tHit > 0.0) {
        col = shade(p, rd);
      } else {
        var g = 0.12 + 0.12 * uv.y;
        col = vec3(g, g * 1.15, g * 1.4);
      }

      output.color = vec4(col, 1.0);
    }
  }
}
