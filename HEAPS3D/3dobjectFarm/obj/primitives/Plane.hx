package obj.primitives;

class Plane implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = AxDefaultShaders.planeShader();

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
