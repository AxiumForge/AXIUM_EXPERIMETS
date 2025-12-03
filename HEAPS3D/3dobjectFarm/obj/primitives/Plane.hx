package obj.primitives;

/**
  Plane - Self-contained plug & play primitive
**/
class Plane implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = new PlaneShader();

    var obj = object();
    var params = obj.sdf.params;
    var mat = obj.material;

    s.planeOffset = params.offset;
    s.planeColor.set(mat.color.r, mat.color.g, mat.color.b);

    return s;
  }

  public function object():PdfObject {
    return {
      name: "Plane",
      sdf: {
        kind: "sdPlane",
        params: {
          offset: -0.5
        }
      },
      transform: {
        position: {x: 0.0, y: 0.0, z: 0.0},
        rotation: {x: 0.0, y: 0.0, z: 0.0},
        scale: {x: 1.0, y: 1.0, z: 1.0}
      },
      material: {
        color: {r: 0.5, g: 0.6, b: 0.7, a: 1.0},
        roughness: 0.5,
        metallic: 0.0
      }
    };
  }
}

/**
  PlaneShader - Contains ALL Plane-specific SDF math and rendering
**/
class PlaneShader extends BaseRaymarchShader {
  static var SRC = {
    @param var planeOffset : Float;
    @param var planeColor : Vec3;

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

    function sdfPlane(p:Vec3, offset:Float):Float {
      return p.y + offset;
    }

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = sdfPlane(pr, planeOffset);
      return vec4(dist, planeColor.x, planeColor.y, planeColor.z);
    }
  };
}
