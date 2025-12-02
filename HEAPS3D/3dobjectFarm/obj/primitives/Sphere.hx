package obj;

import h3d.Vector;

class Sphere {
  public static inline var color = new Vector(0.2, 0.7, 1.0);
  public static inline var radius = 0.55;
  public static inline var center = new Vector(-1.4, 0.0, 0.0);

  public static inline function distance(p:Vector):Float {
    return p.length() - radius;
  }
}
