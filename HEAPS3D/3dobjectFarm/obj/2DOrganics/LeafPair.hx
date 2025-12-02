package obj._2DOrganics;

import h3d.Vector;

class LeafPair {
  public static inline var color = new Vector(0.3, 0.9, 0.5);
  public static inline var length = 0.8;
  public static inline var width = 0.35;
  public static inline var gap = 0.1;

  public static inline function distance(p:Vector):Float {
    var dLeft = leafSDF(new Vector(p.x + gap, p.z));
    var dRight = leafSDF(new Vector(-p.x + gap, p.z));
    return Math.min(dLeft, dRight);
  }

  static inline function leafSDF(p:Vector):Float {
    // teardrop leaf shape
    var qx = Math.abs(p.x) / width;
    var qy = p.y / length;
    var k = Math.max(qx + qy, qy);
    return k - 1.0;
  }
}
