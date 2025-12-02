package obj.primitives2d;

import h3d.Vector;

class Star {
  public static inline var color = new Vector(0.9, 0.8, 0.25);
  public static inline var innerRadius = 0.35;
  public static inline var outerRadius = 0.7;
  public static inline var points = 5;

  public static inline function distance(p:Vector):Float {
    var ang = Math.atan2(p.z, p.x);
    var r = Math.sqrt(p.x * p.x + p.z * p.z);
    var sector = Math.PI * 2.0 / points;
    var a = ((ang % sector) + sector) % sector - sector * 0.5;
    var edge = Math.cos(a) * mix(outerRadius, innerRadius, step(Math.abs(a), sector * 0.25));
    return r - edge;
  }

  static inline function mix(a:Float, b:Float, t:Float):Float {
    return a + (b - a) * t;
  }

  static inline function step(x:Float, edge:Float):Float {
    return x < edge ? 1.0 : 0.0;
  }
}
