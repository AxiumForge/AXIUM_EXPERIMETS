package;

import h3d.shader.ScreenShader;

/**
  SdfSceneShader - Universal scene-based SDF shader (v0.3)

  ONE shader for ALL primitives. Data-driven rendering.

  PoC version: Supports one primitive at a time via shapeType parameter.
  Future: Will support arrays of primitives for complex scenes.
**/
class SdfSceneShader extends ScreenShader {
  static var SRC = {

    @param var time : Float;
    @param var resolution : Vec2;
    @param var cameraPos : Vec3;
    @param var cameraForward : Vec3;
    @param var cameraRight : Vec3;
    @param var cameraUp : Vec3;
    @param var alphaControl : Float;

    // Shape type and parameters
    @param var shapeType : Int;  // 0=box, 1=sphere, 2=capsule, etc.
    @param var shapeParam0 : Vec3;  // Generic param (box: size, sphere: radius in x, etc.)
    @param var shapeParam1 : Vec3;  // Secondary param (capsule: point A, etc.)
    @param var shapeParam2 : Vec3;  // Tertiary param (capsule: point B, etc.)
    @param var shapeColor : Vec3;

    // ========== HELPER FUNCTIONS ==========

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

    // ========== SDF PRIMITIVES (from AxRaymarchLib) ==========

    function sdfBox(p:Vec3, b:Vec3):Float {
      var q = abs(p) - b;
      return length(max(q, vec3(0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);
    }

    function sdfSphere(p:Vec3, r:Float):Float {
      return length(p) - r;
    }

    function sdfCapsule(p:Vec3, a:Vec3, b:Vec3, r:Float):Float {
      var pa = p - a;
      var ba = b - a;
      var h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
      return length(pa - ba * h) - r;
    }

    function sdfCone(p:Vec3, height:Float, radius:Float):Float {
      var h = height;
      var r = radius;
      var q = length(vec2(p.x, p.z));
      return max(dot(vec2(r, h), vec2(q, p.y)) / (r * r + h * h), -p.y - h) * sqrt(r * r + h * h) / r;
    }

    function sdfCylinder(p:Vec3, radius:Float, halfHeight:Float):Float {
      var d = vec2(length(vec2(p.x, p.z)) - radius, abs(p.y) - halfHeight);
      return min(max(d.x, d.y), 0.0) + length(max(d, vec2(0.0)));
    }

    function sdfEllipsoid(p:Vec3, r:Vec3):Float {
      var k0 = length(p / r);
      var k1 = length(p / (r * r));
      return k0 * (k0 - 1.0) / k1;
    }

    function sdfPlane(p:Vec3, offset:Float):Float {
      return p.y + offset;
    }

    function sdfTorus(p:Vec3, majorRadius:Float, minorRadius:Float):Float {
      var q = vec2(length(vec2(p.x, p.z)) - majorRadius, p.y);
      return length(q) - minorRadius;
    }

    function sdfPyramid(p:Vec3, h:Float):Float {
      var m2 = h * h + 0.25;
      var pxz = abs(vec2(p.x, p.z));
      var px = p.x;
      if (pxz.y > pxz.x) {
        pxz = pxz.yx;
        px = p.z;
      }
      pxz -= 0.5;
      var py = p.y - h;
      var q = vec3(pxz.x, py * h + pxz.y * 0.5, pxz.y);
      var s = max(-q.y, 0.0);
      var a = m2 * q.x * q.x - h * h * q.y * q.y;
      var k = clamp((q.x * h + q.y * 0.5) / m2, 0.0, 1.0);
      var b = m2 * (q.x - k * h) * (q.x - k * h) + q.y * q.y - 0.25 * k * k;
      var d = a > 0.0 ? sqrt(a) / m2 : -q.y;
      var d2 = b > 0.0 ? sqrt(b) / m2 : (-q.y - k * 0.5);
      var dist = length(vec2(max(d, s), max(d2, s)));
      return (max(q.y, -py) < 0.0) ? -dist : dist;
    }

    // ========== SCENE MAP (dispatch based on shapeType) ==========

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = 0.0;

      if (shapeType == 0) {  // Box
        dist = sdfBox(pr, shapeParam0);
      } else if (shapeType == 1) {  // Sphere
        dist = sdfSphere(pr, shapeParam0.x);
      } else if (shapeType == 2) {  // Capsule
        dist = sdfCapsule(pr, shapeParam1, shapeParam2, shapeParam0.x);
      } else if (shapeType == 3) {  // Cone
        dist = sdfCone(pr, shapeParam0.x, shapeParam0.y);
      } else if (shapeType == 4) {  // Cylinder
        dist = sdfCylinder(pr, shapeParam0.x, shapeParam0.y);
      } else if (shapeType == 5) {  // Ellipsoid
        dist = sdfEllipsoid(pr, shapeParam0);
      } else if (shapeType == 6) {  // Plane
        dist = sdfPlane(pr, shapeParam0.x);
      } else if (shapeType == 7) {  // Pyramid
        dist = sdfPyramid(pr, shapeParam0.x);
      } else if (shapeType == 8) {  // Torus
        dist = sdfTorus(pr, shapeParam0.x, shapeParam0.y);
      }

      return vec4(dist, shapeColor.x, shapeColor.y, shapeColor.z);
    }

    // ========== RAYMARCHING ==========

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

    // ========== FRAGMENT SHADER ==========

    function fragment() {
      var uv = calculatedUV * 2.0 - 1.0;
      uv.x *= resolution.x / resolution.y;

      var ro = cameraPos;
      var rd = normalize(cameraForward + uv.x * cameraRight + uv.y * cameraUp);

      var rm = raymarch(ro, rd);
      var p = rm.xyz;
      var tHit = rm.w;

      var g = 0.12 + 0.12 * uv.y;
      var background = vec3(g, g * 1.15, g * 1.4);

      var col:Vec3;
      var alpha = alphaControl;

      if (tHit > 0.0) {
        var shaded = shade(p, rd);
        col = mix(background, shaded, alpha);
      } else {
        col = background;
      }

      output.color = vec4(col, 1.0);
    }
  };
}
