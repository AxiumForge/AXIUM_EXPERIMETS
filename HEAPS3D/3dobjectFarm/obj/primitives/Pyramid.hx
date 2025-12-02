package obj;

import h3d.Vector;

class Pyramid {
  public static inline var color = new Vector(0.4, 0.9, 0.5);
  public static inline var height = 0.8;
  public static inline var center = new Vector(1.4, -0.05, 0.0);

  // Square pyramid signed distance (base 1x1 centered, height h)
  public static function distance(p:Vector):Float {
    var h = height;
    var m2 = h * h + 0.25;
    var px = Math.abs(p.x);
    var pz = Math.abs(p.z);
    var swapped = false;
    if (pz > px) {
      var tmp = px;
      px = pz;
      pz = tmp;
      swapped = true;
    }
    px -= 0.5;
    pz -= 0.5;
    var py = p.y - h;
    var qx = px;
    var qy = py * h + pz * 0.5;
    var qz = pz;
    var s = Math.max(-qy, 0.0);
    var a = m2 * qx * qx - h * h * qy * qy;
    var k = clamp((qx * h + qy * 0.5) / m2, 0.0, 1.0);
    var b = m2 * (qx - k * h) * (qx - k * h) + qy * qy - 0.25 * k * k;
    var d = a > 0.0 ? Math.sqrt(a) / m2 : -qy;
    var d2 = b > 0.0 ? Math.sqrt(b) / m2 : (-qy - k * 0.5);
    var dist = Math.sqrt(Math.max(d, s) * Math.max(d, s) + Math.max(d2, s) * Math.max(d2, s));
    return (Math.max(qy, -p.y) < 0.0) ? -dist : dist;
  }

  static inline function clamp(v:Float, lo:Float, hi:Float):Float {
    return v < lo ? lo : (v > hi ? hi : v);
  }
}
