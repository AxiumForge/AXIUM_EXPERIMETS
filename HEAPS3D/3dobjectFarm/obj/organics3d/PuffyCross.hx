package obj.organics3d;

import h3d.Vector;

class PuffyCross {
  public static var color = new Vector(0.6, 0.85, 0.95);
  public static inline var radius = 0.3;
  public static inline var soft = 0.1;

  public static inline function distance(p:Vector):Float {
    var dx = Math.sqrt(p.y * p.y + p.z * p.z) - radius;
    var dy = Math.sqrt(p.x * p.x + p.z * p.z) - radius;
    var dz = Math.sqrt(p.x * p.x + p.y * p.y) - radius;
    var d = Math.min(dx, Math.min(dy, dz));
    var wobble = Math.sin((p.x + p.y + p.z) * 2.0) * soft;
    return d + wobble;
  }
}

class PuffyCrossShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var radius = 0.3;
      var soft = 0.1;

      var dx = length(vec2(pr.y, pr.z)) - radius;
      var dy = length(vec2(pr.x, pr.z)) - radius;
      var dz = length(vec2(pr.x, pr.y)) - radius;
      var d = min(dx, min(dy, dz));
      var wobble = sin((pr.x + pr.y + pr.z) * 2.0) * soft;
      var dist = d + wobble;

      var col = vec3(0.6, 0.85, 0.95);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
