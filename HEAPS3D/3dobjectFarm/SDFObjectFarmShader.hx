package;

import h3d.shader.ScreenShader;

class SDFObjectFarmShader extends ScreenShader {
  static var SRC = {

    @param var time : Float;
    @param var resolution : Vec2;
    @param var cameraPos : Vec3;
    @param var cameraForward : Vec3;
    @param var cameraRight : Vec3;
    @param var cameraUp : Vec3;
    @param var selectedShape : Int;

    // Helpers
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

    // PRIMITIVES
    function sdSphere(p:Vec3, r:Float):Float {
      return length(p) - r;
    }

    function sdBox(p:Vec3, b:Vec3):Float {
      var q = abs(p) - b;
      return length(max(q, vec3(0.0, 0.0, 0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);
    }

    function sdCapsule(p:Vec3, a:Vec3, b:Vec3, r:Float):Float {
      var pa = p - a;
      var ba = b - a;
      var h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
      return length(pa - ba * h) - r;
    }

    function sdTorus(p:Vec3, t:Vec2):Float {
      var q = vec2(length(vec2(p.x, p.z)) - t.x, p.y);
      return length(q) - t.y;
    }

    function sdCone(p:Vec3, h:Float, r:Float):Float {
      var q = length(vec2(p.x, p.z));
      return max(dot(vec2(r, h), vec2(q, p.y)) / (r * r + h * h), -p.y - h) * sqrt(r * r + h * h) / r;
    }

    function sdCylinder(p:Vec3, h:Float, r:Float):Float {
      var d = vec2(length(vec2(p.x, p.z)) - r, abs(p.y) - h);
      return min(max(d.x, d.y), 0.0) + length(max(d, vec2(0.0, 0.0)));
    }

    function sdEllipsoid(p:Vec3, r:Vec3):Float {
      var k0 = length(p / r);
      var k1 = length(p / (r * r));
      return k0 * (k0 - 1.0) / k1;
    }

    function sdPyramid(p:Vec3, h:Float):Float {
      var m2 = h * h + 0.25;
      var pxz = abs(vec2(p.x, p.z));
      if (pxz.y > pxz.x) {
        pxz = pxz.yx;
        p = vec3(p.z, p.y, p.x);
      }
      pxz -= 0.5;
      p.y -= h;
      var q = vec3(pxz.x, p.y * h + pxz.y * 0.5, pxz.y);
      var s = max(-q.y, 0.0);
      var a = m2 * q.x * q.x - h * h * q.y * q.y;
      var k = clamp((q.x * h + q.y * 0.5) / m2, 0.0, 1.0);
      var b = m2 * (q.x - k * h) * (q.x - k * h) + q.y * q.y - 0.25 * k * k;
      var d = a > 0.0 ? sqrt(a) / m2 : -q.y;
      var d2 = b > 0.0 ? sqrt(b) / m2 : (-q.y - k * 0.5);
      var dist = length(vec2(max(d, s), max(d2, s)));
      return (max(q.y, -p.y) < 0.0) ? -dist : dist;
    }

    function sdPlane(p:Vec3):Float {
      return p.y + 1.0;
    }

    // DERIVATES
    function sdHollowSphere(p:Vec3, r:Float, t:Float):Float {
      return abs(length(p) - r) - t;
    }

    function sdHollowBox(p:Vec3, b:Vec3, t:Float):Float {
      var q = abs(p) - b;
      return abs(length(max(q, vec3(0.0, 0.0, 0.0))) + min(max(q.x, max(q.y, q.z)), 0.0)) - t;
    }

    function sdShellCylinder(p:Vec3, h:Float, r:Float, t:Float):Float {
      var d = vec2(length(vec2(p.x, p.z)) - r, abs(p.y) - h);
      var outer = min(max(d.x, d.y), 0.0) + length(max(d, vec2(0.0, 0.0)));
      return abs(outer) - t;
    }

    function opUnionColor(cur:Vec4, dist:Float, col:Vec3):Vec4 {
      return dist < cur.x ? vec4(dist, col.x, col.y, col.z) : cur;
    }

    // scene map: returns (distance, color.rgb)
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = 1e5;
      var col = vec3(0.5, 0.5, 0.5);

      // PRIMITIVES
      if (selectedShape == 0) { // Sphere
        dist = sdSphere(pr, 0.6);
        col = vec3(0.2, 0.7, 1.0);
      } else if (selectedShape == 1) { // Box
        dist = sdBox(pr, vec3(0.5, 0.35, 0.45));
        col = vec3(0.65, 0.35, 0.55);
      } else if (selectedShape == 2) { // Capsule
        dist = sdCapsule(pr, vec3(0.0, -0.4, 0.0), vec3(0.0, 0.4, 0.0), 0.3);
        col = vec3(0.3, 0.85, 0.4);
      } else if (selectedShape == 3) { // Torus
        dist = sdTorus(pr, vec2(0.6, 0.2));
        col = vec3(0.95, 0.55, 0.2);
      } else if (selectedShape == 4) { // Cone
        dist = sdCone(pr, 0.8, 0.5);
        col = vec3(0.85, 0.35, 0.75);
      } else if (selectedShape == 5) { // Cylinder
        dist = sdCylinder(pr, 0.5, 0.4);
        col = vec3(0.4, 0.8, 0.9);
      } else if (selectedShape == 6) { // Ellipsoid
        dist = sdEllipsoid(pr, vec3(0.7, 0.4, 0.5));
        col = vec3(0.9, 0.75, 0.3);
      } else if (selectedShape == 7) { // Pyramid
        dist = sdPyramid(pr, 0.7);
        col = vec3(0.4, 0.9, 0.5);
      } else if (selectedShape == 8) { // Plane
        dist = sdPlane(pr);
        col = vec3(0.6, 0.6, 0.7);
      }
      // DERIVATES
      else if (selectedShape == 9) { // HollowSphere
        dist = sdHollowSphere(pr, 0.65, 0.12);
        col = vec3(0.8, 0.3, 0.7);
      } else if (selectedShape == 10) { // HollowBox
        dist = sdHollowBox(pr, vec3(0.5, 0.4, 0.45), 0.08);
        col = vec3(0.7, 0.5, 0.9);
      } else if (selectedShape == 11) { // ShellCylinder
        dist = sdShellCylinder(pr, 0.5, 0.45, 0.08);
        col = vec3(0.5, 0.9, 0.8);
      }

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
