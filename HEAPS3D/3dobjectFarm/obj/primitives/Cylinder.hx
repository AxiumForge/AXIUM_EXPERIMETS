package obj.primitives;

class Cylinder implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = AxDefaultShaders.cylinderShader();

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
