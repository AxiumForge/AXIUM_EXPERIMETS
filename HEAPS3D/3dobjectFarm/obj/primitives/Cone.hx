package obj.primitives;

/**
  Cone - Self-contained plug & play primitive
**/
class Cone implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    var s = new ConeShader();

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

/**
  ConeShader - Contains ALL Cone-specific SDF math and rendering
**/
class ConeShader extends BaseRaymarchShader {
  static var SRC = {
    @param var coneHeight : Float;
    @param var coneRadius : Float;
    @param var coneColor : Vec3;

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

    function sdfCone(p:Vec3, height:Float, radius:Float):Float {
      var h = height;
      var r = radius;
      var q = length(vec2(p.x, p.z));
      return max(dot(vec2(r, h), vec2(q, p.y)) / (r * r + h * h), -p.y - h) * sqrt(r * r + h * h) / r;
    }

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = sdfCone(pr, coneHeight, coneRadius);
      return vec4(dist, coneColor.x, coneColor.y, coneColor.z);
    }
  };
}
