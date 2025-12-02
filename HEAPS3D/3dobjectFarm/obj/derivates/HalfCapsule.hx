package obj.derivates;

import h3d.Vector;

class HalfCapsule {
  public static inline var color = new Vector(0.95, 0.45, 0.6);
  public static inline var a = new Vector(-0.6, -0.3, 0.8);
  public static inline var b = new Vector(0.5, 0.6, 0.8);
  public static inline var radius = 0.2;

  public static inline function distance(p:Vector):Float {
    // only keep positive Z half-space
    if (p.z < 0.0) {
      p = new Vector(p.x, p.y, Math.abs(p.z));
    }
    var paX = p.x - a.x;
    var paY = p.y - a.y;
    var paZ = p.z - a.z;
    var baX = b.x - a.x;
    var baY = b.y - a.y;
    var baZ = b.z - a.z;
    var baLen2 = baX * baX + baY * baY + baZ * baZ;
    var h = clamp((paX * baX + paY * baY + paZ * baZ) / baLen2, 0.0, 1.0);
    var dx = paX - baX * h;
    var dy = paY - baY * h;
    var dz = paZ - baZ * h;
    return Math.sqrt(dx * dx + dy * dy + dz * dz) - radius;
  }

  static inline function clamp(v:Float, lo:Float, hi:Float):Float {
    return v < lo ? lo : (v > hi ? hi : v);
  }
}
