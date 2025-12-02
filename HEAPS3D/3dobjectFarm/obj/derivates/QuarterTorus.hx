package obj.derivates;

import h3d.Vector;

class QuarterTorus {
  public static var color = new Vector(0.95, 0.65, 0.25);
  public static var majorMinor = new Vector(0.75, 0.18, 0.0);
  public static var center = new Vector(1.4, 0.4, -0.8);

  public static inline function distance(p:Vector):Float {
    if (p.x < 0.0 || p.z < 0.0) {
      var bx = Math.abs(p.x);
      var bz = Math.abs(p.z);
      p = new Vector(bx, p.y, bz);
    }
    var qx = Math.sqrt(p.x * p.x + p.z * p.z) - majorMinor.x;
    var qy = p.y;
    return Math.sqrt(qx * qx + qy * qy) - majorMinor.y;
  }
}

class QuarterTorusShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var prx = abs(pr.x);
      var prz = abs(pr.z);
      var pr2 = vec3(prx, pr.y, prz);
      var t = vec2(0.6, 0.18);
      var q = vec2(length(vec2(pr2.x, pr2.z)) - t.x, pr2.y);
      var dist = length(q) - t.y;
      var col = vec3(0.95, 0.65, 0.25);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
