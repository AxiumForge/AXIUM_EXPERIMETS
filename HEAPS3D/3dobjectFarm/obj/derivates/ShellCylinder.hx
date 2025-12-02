package obj.derivates;

import h3d.Vector;

class ShellCylinder {
  public static inline var color = new Vector(0.25, 0.8, 0.9);
  public static inline var radius = 0.55;
  public static inline var halfHeight = 0.7;
  public static inline var thickness = 0.08;
  public static inline var center = new Vector(-2.0, -0.1, -0.9);

  public static inline function distance(p:Vector):Float {
    var outer = sdCyl(p, radius, halfHeight);
    var inner = sdCyl(p, radius - thickness, halfHeight - thickness);
    return Math.max(outer, -inner);
  }

  static inline function sdCyl(p:Vector, r:Float, h:Float):Float {
    var dx = Math.sqrt(p.x * p.x + p.z * p.z) - r;
    var dy = Math.abs(p.y) - h;
    var ax = Math.max(dx, 0.0);
    var ay = Math.max(dy, 0.0);
    var outside = Math.sqrt(ax * ax + ay * ay);
    var inside = Math.min(Math.max(dx, dy), 0.0);
    return outside + inside;
  }
}
