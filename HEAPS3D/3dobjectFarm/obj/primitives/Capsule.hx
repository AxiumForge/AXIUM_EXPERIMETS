package obj.primitives;

/**
  Capsule - Self-contained plug & play primitive
**/
class Capsule implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = new CapsuleShader();

    var obj = object();
    var params = obj.sdf.params;
    var mat = obj.material;

    s.capsuleA.set(params.a.x, params.a.y, params.a.z);
    s.capsuleB.set(params.b.x, params.b.y, params.b.z);
    s.capsuleRadius = params.radius;
    s.capsuleColor.set(mat.color.r, mat.color.g, mat.color.b);

    return s;
  }

  public function object():PdfObject {
    return {
      name: "Capsule",
      sdf: {
        kind: "sdCapsule",
        params: {
          a: {x: 0.0, y: -0.4, z: 0.0},
          b: {x: 0.0, y: 0.4, z: 0.0},
          radius: 0.3
        }
      },
      transform: {
        position: {x: 0.0, y: 0.0, z: 0.0},
        rotation: {x: 0.0, y: 0.0, z: 0.0},
        scale: {x: 1.0, y: 1.0, z: 1.0}
      },
      material: {
        color: {r: 0.3, g: 0.85, b: 0.4, a: 1.0},
        roughness: 0.5,
        metallic: 0.0
      }
    };
  }
}

/**
  CapsuleShader - Contains ALL Capsule-specific SDF math and rendering
**/
class CapsuleShader extends BaseRaymarchShader {
  static var SRC = {
    @param var capsuleA : Vec3;
    @param var capsuleB : Vec3;
    @param var capsuleRadius : Float;
    @param var capsuleColor : Vec3;

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

    function sdfCapsule(p:Vec3, a:Vec3, b:Vec3, r:Float):Float {
      var pa = p - a;
      var ba = b - a;
      var h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
      return length(pa - ba * h) - r;
    }

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = sdfCapsule(pr, capsuleA, capsuleB, capsuleRadius);
      return vec4(dist, capsuleColor.x, capsuleColor.y, capsuleColor.z);
    }
  };
}
