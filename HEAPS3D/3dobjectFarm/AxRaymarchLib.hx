package;

import h3d.shader.ScreenShader;

/**
  AxRaymarchLib - Universal SDF primitive library

  Contains all SDF distance functions for primitives.
  Used by SdfSceneShader for scene composition.

  Based on Inigo Quilez's distance functions.
**/
class AxRaymarchLib extends ScreenShader {
  static var SRC = {

    // ========== SDF PRIMITIVE FUNCTIONS ==========

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

    function sdfPyramid(p:Vec3, h:Float):Float {
      var m2 = h * h + 0.25;
      var pxz = abs(vec2(p.x, p.z));
      var px = p.x;
      var pz = p.z;
      if (pxz.y > pxz.x) {
        pxz = pxz.yx;
        px = p.z;
        pz = p.x;
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

    function sdfTorus(p:Vec3, majorRadius:Float, minorRadius:Float):Float {
      var q = vec2(length(vec2(p.x, p.z)) - majorRadius, p.y);
      return length(q) - minorRadius;
    }

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

    function rotateY(p:Vec3, angle:Float):Vec3 {
      var c = cos(angle);
      var s = sin(angle);
      return vec3(p.x * c + p.z * s, p.y, -p.x * s + p.z * c);
    }
  };
}
