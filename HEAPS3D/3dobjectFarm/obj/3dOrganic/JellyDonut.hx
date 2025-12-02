package obj._3dOrganic;

import h3d.Vector;

class JellyDonut {
  public static inline var color = new Vector(0.95, 0.3, 0.55);
  public static inline var major = 0.9;
  public static inline var minor = 0.28;
  public static inline var jelly = 0.12;

  public static inline function distance(p:Vector):Float {
    var qx = Math.sqrt(p.x * p.x + p.z * p.z) - major;
    var qy = p.y;
    var base = Math.sqrt(qx * qx + qy * qy) - minor;
    var wobble = Math.sin((p.x + p.y) * 2.2) * jelly;
    return base + wobble;
  }
}

class JellyDonutShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var major = 0.9;
      var minor = 0.28;
      var jelly = 0.12;

      var q = vec2(length(pr.xz) - major, pr.y);
      var base = length(q) - minor;
      var wobble = sin((pr.x + pr.y) * 2.2) * jelly;
      var dist = base + wobble;

      var col = vec3(0.95, 0.3, 0.55);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
