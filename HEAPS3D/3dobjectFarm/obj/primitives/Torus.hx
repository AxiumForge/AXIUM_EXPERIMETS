package obj;

import h3d.Vector;

class Torus {
  public static inline var color = new Vector(0.95, 0.55, 0.2);
  public static inline var majorMinor = new Vector(0.7, 0.18, 0.0); // x = major radius, y = minor radius
  public static inline var center = new Vector(0.0, 0.6, 0.0);

  public static inline function distance(p:Vector):Float {
    var qx = Math.sqrt(p.x * p.x + p.z * p.z) - majorMinor.x;
    var qy = p.y;
    return Math.sqrt(qx * qx + qy * qy) - majorMinor.y;
  }
}
