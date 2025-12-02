package obj._3dOrganic;

import h3d.Vector;

class KnotTube {
  public static inline var color = new Vector(0.9, 0.65, 0.3);
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
