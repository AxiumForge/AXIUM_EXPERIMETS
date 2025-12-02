package obj._3dOrganic;

import h3d.Vector;

class MeltedBox {
  public static inline var color = new Vector(0.7, 0.4, 0.3);
  public static inline var halfExtents = new Vector(0.6, 0.4, 0.5);
  public static inline var melt = 0.18;

  public static inline function distance(p:Vector):Float {
    var qx = Math.abs(p.x) - halfExtents.x;
    var qy = Math.abs(p.y) - halfExtents.y;
    var qz = Math.abs(p.z) - halfExtents.z;
    var ax = Math.max(qx, 0.0);
    var ay = Math.max(qy, 0.0);
    var az = Math.max(qz, 0.0);
    var outside = Math.sqrt(ax * ax + ay * ay + az * az);
    var inside = Math.min(Math.max(qx, Math.max(qy, qz)), 0.0);
    var base = outside + inside;
    var blob = Math.sin((p.x + p.y + p.z) * 1.6) * melt;
    return base + blob;
  }
}
