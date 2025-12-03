package obj.primitives;

/**
  Torus - Self-contained plug & play primitive
**/
class Torus implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = new TorusShader();

    var obj = object();
    var params = obj.sdf.params;
    var mat = obj.material;

    s.torusMajorRadius = params.majorRadius;
    s.torusMinorRadius = params.minorRadius;
    s.torusColor.set(mat.color.r, mat.color.g, mat.color.b);

    return s;
  }

  public function object():PdfObject {
    return {
      name: "Torus",
      sdf: {
        kind: "sdTorus",
        params: {
          majorRadius: 0.5,
          minorRadius: 0.2
        }
      },
      transform: {
        position: {x: 0.0, y: 0.0, z: 0.0},
        rotation: {x: 0.0, y: 0.0, z: 0.0},
        scale: {x: 1.0, y: 1.0, z: 1.0}
      },
      material: {
        color: {r: 0.2, g: 0.6, b: 0.9, a: 1.0},
        roughness: 0.5,
        metallic: 0.0
      }
    };
  }
}

/**
  TorusShader - Contains ALL Torus-specific SDF math and rendering
**/
class TorusShader extends BaseRaymarchShader {
  static var SRC = {
    @param var torusMajorRadius : Float;
    @param var torusMinorRadius : Float;
    @param var torusColor : Vec3;

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

    function sdfTorus(p:Vec3, majorRadius:Float, minorRadius:Float):Float {
      var q = vec2(length(vec2(p.x, p.z)) - majorRadius, p.y);
      return length(q) - minorRadius;
    }

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = sdfTorus(pr, torusMajorRadius, torusMinorRadius);
      return vec4(dist, torusColor.x, torusColor.y, torusColor.z);
    }
  };
}
