package obj.organics3d;

import h3d.Vector;

class KnotTube {
  public static var color = new Vector(0.9, 0.65, 0.3);
  public static inline var radius = 0.18;
  public static inline var major = 0.9;
  public static inline var twist = 2.5;

  public static inline function distance(p:Vector):Float {
    // simple trefoil-like mapping
    var qx = major + Math.cos(3.0 * Math.atan2(p.y, p.x)) * 0.2;
    var qz = Math.sin(3.0 * Math.atan2(p.y, p.x)) * 0.2;
    var dx = Math.sqrt(p.x * p.x + p.y * p.y) - qx;
    var dy = p.z - qz;
    return Math.sqrt(dx * dx + dy * dy) - radius;
  }
}

class KnotTubeShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var radius = 0.18;
      var major = 0.9;

      var ang = atan(pr.y / pr.x);
      var qx = major + cos(3.0 * ang) * 0.2;
      var qz = sin(3.0 * ang) * 0.2;
      var dx = length(vec2(pr.x, pr.y)) - qx;
      var dy = pr.z - qz;
      var dist = length(vec2(dx, dy)) - radius;

      var col = vec3(0.9, 0.65, 0.3);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
