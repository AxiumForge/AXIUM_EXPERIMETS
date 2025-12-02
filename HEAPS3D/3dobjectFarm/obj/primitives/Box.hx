package obj;

import h3d.Vector;

class Box {
  public static inline var color = new Vector(0.65, 0.35, 0.55);
  public static inline var halfExtents = new Vector(0.5, 0.35, 0.45);
  public static inline var center = new Vector(-2.2, -0.1, 0.3);

  public static inline function distance(p:Vector):Float {
    var qx = Math.abs(p.x) - halfExtents.x;
    var qy = Math.abs(p.y) - halfExtents.y;
    var qz = Math.abs(p.z) - halfExtents.z;
    var ax = Math.max(qx, 0.0);
    var ay = Math.max(qy, 0.0);
    var az = Math.max(qz, 0.0);
    var outside = Math.sqrt(ax * ax + ay * ay + az * az);
    var inside = Math.min(Math.max(qx, Math.max(qy, qz)), 0.0);
    return outside + inside;
  }
}
