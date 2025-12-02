package obj.derivates;

import h3d.Vector;

class HollowSphere {
  public static inline var color = new Vector(0.8, 0.3, 0.7);
  public static inline var outerRadius = 0.8;
  public static inline var thickness = 0.12;
  public static inline var center = new Vector(-1.6, 0.1, 0.0);

  public static inline function distance(p:Vector):Float {
    var d = p.length();
    var inner = outerRadius - thickness;
    return Math.abs(d - outerRadius) - thickness * 0.5 + Math.min(d - inner, 0.0);
  }
}
