package obj.primitives;

class Sphere implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = AxDefaultShaders.sphereShader();

    var obj = object();
    var params = obj.sdf.params;
    var mat = obj.material;

    s.sphereRadius = params.radius;
    s.sphereColor.set(mat.color.r, mat.color.g, mat.color.b);

    return s;
  }

  public function object():PdfObject {
    return {
      name: "Sphere",
      sdf: {
        kind: "sdSphere",
        params: {
          radius: 0.5
        }
      },
      transform: {
        position: {x: 0.0, y: 0.0, z: 0.0},
        rotation: {x: 0.0, y: 0.0, z: 0.0},
        scale: {x: 1.0, y: 1.0, z: 1.0}
      },
      material: {
        color: {r: 0.8, g: 0.2, b: 0.2, a: 1.0},
        roughness: 0.5,
        metallic: 0.0
      }
    };
  }
}
