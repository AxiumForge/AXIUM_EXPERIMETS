package obj._2DOrganics;

import h3d.Vector;

class VineCurl {
  public static inline var color = new Vector(0.2, 0.75, 0.45);
  public static inline var thickness = 0.1;

  public static inline function distance(p:Vector):Float {
    var r = Math.sqrt(p.x * p.x + p.z * p.z);
    var a = Math.atan2(p.z, p.x);
    var target = 0.3 + 0.12 * a;
    return Math.abs(r - target) - thickness;
  }
}
