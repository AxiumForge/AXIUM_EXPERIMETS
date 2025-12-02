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
