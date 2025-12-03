package obj.primitives;

/**
  Box - Self-contained plug & play primitive
  Contains BOTH AxObjectClass interface implementation AND BoxShader with SDF math
**/
class Box implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = new BoxShader();

    // Configure shader from object() data
    var obj = object();
    var params = obj.sdf.params;
    var mat = obj.material;

    s.boxSize.set(params.halfExtents.x, params.halfExtents.y, params.halfExtents.z);
    s.boxColor.set(mat.color.r, mat.color.g, mat.color.b);

    return s;
  }

  public function object():PdfObject {
    return {
      name: "Box",
      sdf: {
        kind: "sdBox",
        params: {
          halfExtents: {x: 0.5, y: 0.35, z: 0.45}
        }
      },
      transform: {
        position: {x: 0.0, y: 0.0, z: 0.0},
        rotation: {x: 0.0, y: 0.0, z: 0.0},
        scale: {x: 1.0, y: 1.0, z: 1.0}
      },
      material: {
        color: {r: 0.65, g: 0.35, b: 0.55, a: 1.0},
        roughness: 0.5,
        metallic: 0.0
      }
    };
  }
}

/**
  BoxShader - Contains ALL Box-specific SDF math and rendering
  Extends BaseRaymarchShader for world-level raymarching + lighting
**/
class BoxShader extends BaseRaymarchShader {
  static var SRC = {
    // Inherits from BaseRaymarchShader: time, resolution, cameraPos, cameraForward, cameraRight, cameraUp, alphaControl

    // Box-specific uniforms
    @param var boxSize : Vec3;
    @param var boxColor : Vec3;

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

    // ========== SDF PRIMITIVE (Box-specific math) ==========

    function sdfBox(p:Vec3, b:Vec3):Float {
      var q = abs(p) - b;
      return length(max(q, vec3(0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);
    }

    // ========== SCENE MAP (Box-specific) ==========

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = sdfBox(pr, boxSize);
      return vec4(dist, boxColor.x, boxColor.y, boxColor.z);
    }
  };
}
