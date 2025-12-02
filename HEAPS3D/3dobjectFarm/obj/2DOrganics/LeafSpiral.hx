package obj._2DOrganics;

import h3d.Vector;

class LeafSpiral {
  public static inline var color = new Vector(0.35, 0.9, 0.55);
  public static inline var turns = 2.5;
  public static inline var width = 0.18;

  public static inline function distance(p:Vector):Float {
    var ang = Math.atan2(p.z, p.x);
    var r = Math.sqrt(p.x * p.x + p.z * p.z);
    var target = 0.25 + 0.2 * (ang / (Math.PI * 2.0) * turns);
    var leaf = Math.abs(r - target) - width;
    var vein = Math.abs(p.z) * 0.1;
    return leaf + vein;
  }
}
