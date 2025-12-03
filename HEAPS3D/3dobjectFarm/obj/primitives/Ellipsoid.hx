package obj.primitives;

class Ellipsoid implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = AxDefaultShaders.ellipsoidShader();

    var obj = object();
    var params = obj.sdf.params;
    var mat = obj.material;

    s.ellipsoidRadii.set(params.radii.x, params.radii.y, params.radii.z);
    s.ellipsoidColor.set(mat.color.r, mat.color.g, mat.color.b);

    return s;
  }

  public function object():PdfObject {
    return {
      name: "Ellipsoid",
      sdf: {
        kind: "sdEllipsoid",
        params: {
          radii: {x: 0.7, y: 0.4, z: 0.5}
        }
      },
      transform: {
        position: {x: 0.0, y: 0.0, z: 0.0},
        rotation: {x: 0.0, y: 0.0, z: 0.0},
        scale: {x: 1.0, y: 1.0, z: 1.0}
      },
      material: {
        color: {r: 0.9, g: 0.75, b: 0.3, a: 1.0},
        roughness: 0.5,
        metallic: 0.0
      }
    };
  }
}
