package obj._3dOrganic;

import h3d.Vector;

class BubbleCrown {
  public static inline var color = new Vector(0.7, 0.95, 0.9);
  public static inline var baseRadius = 0.4;
  public static inline var lift = 0.5;

  public static inline function distance(p:Vector):Float {
    var d0 = new Vector(p.x, p.y - lift, p.z).length() - baseRadius;
    var d1 = new Vector(p.x + 0.3, p.y - lift + 0.15, p.z).length() - baseRadius * 0.8;
    var d2 = new Vector(p.x - 0.25, p.y - lift + 0.1, p.z + 0.3).length() - baseRadius * 0.7;
    var d3 = new Vector(p.x, p.y - lift + 0.2, p.z - 0.25).length() - baseRadius * 0.65;
    return Math.min(Math.min(d0, d1), Math.min(d2, d3));
  }
}
