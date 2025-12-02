package obj._3dOrganic;

import h3d.Vector;

class SoftSphereWrap {
  public static inline var color = new Vector(0.75, 0.4, 0.9);
  public static inline var baseRadius = 0.7;
  public static inline var wobble = 0.12;
  public static inline var freq = 3.5;
  public static inline var center = new Vector(-1.2, 0.2, 0.0);

  public static inline function distance(p:Vector, time:Float):Float {
    var d = p.length();
    var ripple = Math.sin((p.x + p.y + p.z) * freq + time * 1.5) * wobble;
    return d - (baseRadius + ripple);
  }
}
