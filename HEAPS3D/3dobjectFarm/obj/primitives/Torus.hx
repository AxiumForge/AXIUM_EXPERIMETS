package obj.primitives;

class Torus implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = AxDefaultShaders.torusShader();

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
