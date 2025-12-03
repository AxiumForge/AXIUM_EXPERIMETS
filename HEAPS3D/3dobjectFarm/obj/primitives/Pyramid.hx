package obj.primitives;

/**
  Pyramid - Self-contained plug & play primitive
**/
class Pyramid implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = new PyramidShader();

    var obj = object();
    var params = obj.sdf.params;
    var mat = obj.material;

    s.pyramidHeight = params.height;
    s.pyramidColor.set(mat.color.r, mat.color.g, mat.color.b);

    return s;
  }

  public function object():PdfObject {
    return {
      name: "Pyramid",
      sdf: {
        kind: "sdPyramid",
        params: {
          height: 0.6
        }
      },
      transform: {
        position: {x: 0.0, y: 0.0, z: 0.0},
        rotation: {x: 0.0, y: 0.0, z: 0.0},
        scale: {x: 1.0, y: 1.0, z: 1.0}
      },
      material: {
        color: {r: 0.95, g: 0.8, b: 0.4, a: 1.0},
        roughness: 0.5,
        metallic: 0.0
      }
    };
  }
}

/**
  PyramidShader - Contains ALL Pyramid-specific SDF math and rendering
**/
class PyramidShader extends BaseRaymarchShader {
  static var SRC = {
    @param var pyramidHeight : Float;
    @param var pyramidColor : Vec3;

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

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = sdfPyramid(pr, pyramidHeight);
      return vec4(dist, pyramidColor.x, pyramidColor.y, pyramidColor.z);
    }
  };
}
