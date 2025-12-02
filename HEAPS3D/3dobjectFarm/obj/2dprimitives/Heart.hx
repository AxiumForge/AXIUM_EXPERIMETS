package obj.primitives2d;

import h3d.Vector;

class Heart {
  public static inline var color = new Vector(0.9, 0.3, 0.35);
  public static inline var scale = 1.0;

  public static inline function distance(p:Vector):Float {
    // normalized heart implicit curve approx
    var x = p.x * scale;
    var y = p.z * scale;
    var a = x * x + y * y - 1.0;
    return (a * a * a - x * x * y * y * y) / (scale * 3.0);
  }
}
