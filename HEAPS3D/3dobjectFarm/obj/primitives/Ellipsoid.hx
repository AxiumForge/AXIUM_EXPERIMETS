package obj.primitives;

/**
  Ellipsoid - Self-contained plug & play primitive
**/
class Ellipsoid implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = new EllipsoidShader();

    var obj = object();
    var params = obj.sdf.params;
    var mat = obj.material;

    s.ellipsoidRadii.set(params.radii.x, params.radii.y, params.radii.z);
    s.ellipsoidColor.set(mat.color.r, mat.color.g, mat.color.b);

    return s;
  }

  public function object():PdfObject {
    return {
      name: "Ellipsoid",
      sdf: {
        kind: "sdEllipsoid",
        params: {
          radii: {x: 0.7, y: 0.4, z: 0.5}
        }
      },
      transform: {
        position: {x: 0.0, y: 0.0, z: 0.0},
        rotation: {x: 0.0, y: 0.0, z: 0.0},
        scale: {x: 1.0, y: 1.0, z: 1.0}
      },
      material: {
        color: {r: 0.9, g: 0.75, b: 0.3, a: 1.0},
        roughness: 0.5,
        metallic: 0.0
      }
    };
  }
}

/**
  EllipsoidShader - Contains ALL Ellipsoid-specific SDF math and rendering
**/
class EllipsoidShader extends BaseRaymarchShader {
  static var SRC = {
    @param var ellipsoidRadii : Vec3;
    @param var ellipsoidColor : Vec3;

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

    function sdfEllipsoid(p:Vec3, r:Vec3):Float {
      var k0 = length(p / r);
      var k1 = length(p / (r * r));
      return k0 * (k0 - 1.0) / k1;
    }

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = sdfEllipsoid(pr, ellipsoidRadii);
      return vec4(dist, ellipsoidColor.x, ellipsoidColor.y, ellipsoidColor.z);
    }
  };
}
