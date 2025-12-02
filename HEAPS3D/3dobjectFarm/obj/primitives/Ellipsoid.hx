package obj;

import h3d.Vector;

class Ellipsoid {
  public static inline var color = new Vector(0.15, 0.9, 0.6);
  public static inline var radii = new Vector(0.9, 0.5, 0.35);
  public static inline var center = new Vector(0.0, -0.4, -1.6);

  public static inline function distance(p:Vector):Float {
    var k0 = new Vector(p.x / radii.x, p.y / radii.y, p.z / radii.z);
    var k1 = new Vector(p.x / (radii.x * radii.x), p.y / (radii.y * radii.y), p.z / (radii.z * radii.z));
    var s = 1.0 / Math.sqrt(k0.x * k0.x + k0.y * k0.y + k0.z * k0.z);
    return (p.x * k1.x + p.y * k1.y + p.z * k1.z) * s - 1.0;
  }
}
