package obj._2DOrganics;

import h3d.Vector;

class OrnateKnot {
  public static inline var color = new Vector(0.8, 0.55, 0.2);
  public static inline var radius = 0.45;
  public static inline var thickness = 0.12;

  public static inline function distance(p:Vector):Float {
    var u = p.x;
    var v = p.z;
    var r = Math.sqrt(u * u + v * v);
    var theta = Math.atan2(v, u);
    var knot = radius + 0.1 * Math.sin(3.0 * theta);
    return Math.abs(r - knot) - thickness;
  }
}
