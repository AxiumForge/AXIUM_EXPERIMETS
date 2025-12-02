package obj.primitives2d;

import h3d.Vector;

class RoundedBox2D {
  public static inline var color = new Vector(0.65, 0.7, 0.2);
  public static inline var halfExtents = new Vector(0.8, 0.0, 0.5);
  public static inline var radius = 0.15;
  public static inline var center = new Vector(0.0, 0.0, 0.0);

  public static inline function distance(p:Vector):Float {
    var qx = Math.abs(p.x) - (halfExtents.x - radius);
    var qz = Math.abs(p.z) - (halfExtents.z - radius);
    var ax = Math.max(qx, 0.0);
    var az = Math.max(qz, 0.0);
    return Math.sqrt(ax * ax + az * az) - radius + Math.min(Math.max(qx, qz), 0.0);
  }
}
