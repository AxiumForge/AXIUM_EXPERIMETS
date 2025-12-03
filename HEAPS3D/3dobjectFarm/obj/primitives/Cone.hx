package obj.primitives;

class Cone implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = AxDefaultShaders.coneShader();

    var obj = object();
    var params = obj.sdf.params;
    var mat = obj.material;

    s.coneHeight = params.height;
    s.coneRadius = params.radius;
    s.coneColor.set(mat.color.r, mat.color.g, mat.color.b);

    return s;
  }

  public function object():PdfObject {
    return {
      name: "Cone",
      sdf: {
        kind: "sdCone",
        params: {
          height: 0.8,
          radius: 0.5
        }
      },
      transform: {
        position: {x: 0.0, y: 0.0, z: 0.0},
        rotation: {x: 0.0, y: 0.0, z: 0.0},
        scale: {x: 1.0, y: 1.0, z: 1.0}
      },
      material: {
        color: {r: 0.85, g: 0.35, b: 0.75, a: 1.0},
        roughness: 0.5,
        metallic: 0.0
      }
    };
  }
}
