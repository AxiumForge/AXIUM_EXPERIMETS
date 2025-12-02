package obj;

import h3d.Vector;

class Cylinder {
  public static inline var color = new Vector(0.3, 0.8, 0.8);
  public static inline var radius = 0.4;
  public static inline var halfHeight = 0.65;
  public static inline var center = new Vector(2.1, 0.0, -0.3);

  public static inline function distance(p:Vector):Float {
    var qx = Math.sqrt(p.x * p.x + p.z * p.z) - radius;
    var qy = Math.abs(p.y) - halfHeight;
    var ax = Math.max(qx, 0.0);
    var ay = Math.max(qy, 0.0);
    var outside = Math.sqrt(ax * ax + ay * ay);
    var inside = Math.min(Math.max(qx, qy), 0.0);
    return outside + inside;
  }
}
