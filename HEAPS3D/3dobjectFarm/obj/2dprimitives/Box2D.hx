package obj.primitives2d;

import h3d.Vector;

class Box2D {
  public static inline var color = new Vector(0.9, 0.4, 0.3);
  public static inline var halfExtents = new Vector(0.7, 0.0, 0.45);
  public static inline var center = new Vector(0.0, 0.0, 0.0);

  public static inline function distance(p:Vector):Float {
    var qx = Math.abs(p.x) - halfExtents.x;
    var qz = Math.abs(p.z) - halfExtents.z;
    var ax = Math.max(qx, 0.0);
    var az = Math.max(qz, 0.0);
    var outside = Math.sqrt(ax * ax + az * az);
    var inside = Math.min(Math.max(qx, qz), 0.0);
    return outside + inside;
  }
}
