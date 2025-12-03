package obj.primitives;

/**
  Cylinder - Self-contained plug & play primitive
**/
class Cylinder implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = new CylinderShader();

    var obj = object();
    var params = obj.sdf.params;
    var mat = obj.material;

    s.cylinderRadius = params.radius;
    s.cylinderHalfHeight = params.halfHeight;
    s.cylinderColor.set(mat.color.r, mat.color.g, mat.color.b);

    return s;
  }

  public function object():PdfObject {
    return {
      name: "Cylinder",
      sdf: {
        kind: "sdCylinder",
        params: {
          radius: 0.4,
          halfHeight: 0.5
        }
      },
      transform: {
        position: {x: 0.0, y: 0.0, z: 0.0},
        rotation: {x: 0.0, y: 0.0, z: 0.0},
        scale: {x: 1.0, y: 1.0, z: 1.0}
      },
      material: {
        color: {r: 0.4, g: 0.8, b: 0.9, a: 1.0},
        roughness: 0.5,
        metallic: 0.0
      }
    };
  }
}

/**
  CylinderShader - Contains ALL Cylinder-specific SDF math and rendering
**/
class CylinderShader extends BaseRaymarchShader {
  static var SRC = {
    @param var cylinderRadius : Float;
    @param var cylinderHalfHeight : Float;
    @param var cylinderColor : Vec3;

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

    function sdfCylinder(p:Vec3, radius:Float, halfHeight:Float):Float {
      var d = vec2(length(vec2(p.x, p.z)) - radius, abs(p.y) - halfHeight);
      return min(max(d.x, d.y), 0.0) + length(max(d, vec2(0.0)));
    }

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = sdfCylinder(pr, cylinderRadius, cylinderHalfHeight);
      return vec4(dist, cylinderColor.x, cylinderColor.y, cylinderColor.z);
    }
  };
}
