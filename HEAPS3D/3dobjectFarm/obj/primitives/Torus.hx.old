package obj.primitives;

import h3d.Vector;

class Torus {
  public static var color = new Vector(0.95, 0.55, 0.2);
  public static var majorMinor = new Vector(0.7, 0.18, 0.0);
  public static var center = new Vector(0.0, 0.6, 0.0);

  public static inline function distance(p:Vector):Float {
    var qx = Math.sqrt(p.x * p.x + p.z * p.z) - majorMinor.x;
    var qy = p.y;
    return Math.sqrt(qx * qx + qy * qy) - majorMinor.y;
  }
}

class TorusShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var t = vec2(0.6, 0.2);
      var q = vec2(length(vec2(pr.x, pr.z)) - t.x, pr.y);
      var dist = length(q) - t.y;
      var col = vec3(0.95, 0.55, 0.2);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
