package obj.primitives;

class Capsule implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = AxDefaultShaders.capsuleShader();

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
