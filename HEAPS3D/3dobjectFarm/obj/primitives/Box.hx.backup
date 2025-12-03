package obj.primitives;

class Box implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = AxDefaultShaders.boxShader();

    // Set Box-specific uniforms from object() data
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
