package obj.derivates;

import h3d.Vector;

class HollowBox {
  public static inline var color = new Vector(0.55, 0.75, 0.3);
  public static inline var halfExtents = new Vector(0.7, 0.45, 0.5);
  public static inline var thickness = 0.08;
  public static inline var center = new Vector(0.2, -0.2, 1.2);

  public static inline function distance(p:Vector):Float {
    var outer = sdBox(p, halfExtents);
    var inner = sdBox(p, new Vector(halfExtents.x - thickness, halfExtents.y - thickness, halfExtents.z - thickness));
    return Math.max(outer, -inner);
  }

  static inline function sdBox(p:Vector, b:Vector):Float {
    var qx = Math.abs(p.x) - b.x;
    var qy = Math.abs(p.y) - b.y;
    var qz = Math.abs(p.z) - b.z;
    var ax = Math.max(qx, 0.0);
    var ay = Math.max(qy, 0.0);
    var az = Math.max(qz, 0.0);
    var outside = Math.sqrt(ax * ax + ay * ay + az * az);
    var inside = Math.min(Math.max(qx, Math.max(qy, qz)), 0.0);
    return outside + inside;
  }
}
