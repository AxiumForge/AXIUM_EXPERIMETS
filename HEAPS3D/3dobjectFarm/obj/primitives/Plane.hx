package obj;

import h3d.Vector;

class Plane {
  public static inline var color = new Vector(0.9, 0.9, 0.95);
  public static inline var normal = new Vector(0, 1, 0);
  public static inline var offset = -0.9; // y = -offset

  public static inline function distance(p:Vector):Float {
    return p.x * normal.x + p.y * normal.y + p.z * normal.z + offset;
  }
}
