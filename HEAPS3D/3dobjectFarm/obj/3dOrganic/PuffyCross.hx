package obj._3dOrganic;

import h3d.Vector;

class PuffyCross {
  public static inline var color = new Vector(0.6, 0.85, 0.95);
  public static inline var radius = 0.3;
  public static inline var soft = 0.1;

  public static inline function distance(p:Vector):Float {
    var dx = Math.sqrt(p.y * p.y + p.z * p.z) - radius;
    var dy = Math.sqrt(p.x * p.x + p.z * p.z) - radius;
    var dz = Math.sqrt(p.x * p.x + p.y * p.y) - radius;
    var d = Math.min(dx, Math.min(dy, dz));
    var wobble = Math.sin((p.x + p.y + p.z) * 2.0) * soft;
    return d + wobble;
  }
}
