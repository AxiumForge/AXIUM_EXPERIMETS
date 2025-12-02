package obj.derivates;

import h3d.Vector;

class QuarterTorus {
  public static inline var color = new Vector(0.95, 0.65, 0.25);
  public static inline var majorMinor = new Vector(0.75, 0.18, 0.0);
  public static inline var center = new Vector(1.4, 0.4, -0.8);

  public static inline function distance(p:Vector):Float {
    // cut to positive X and Z to keep quarter
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
