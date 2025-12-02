package obj;

import h3d.Vector;

class Cone {
  public static inline var color = new Vector(0.85, 0.35, 0.75);
  public static inline var height = 1.0;
  public static inline var radius = 0.6;
  public static inline var center = new Vector(-0.2, -0.2, 1.2);

  // finite cone with rounded tip at apex
  public static function distance(p:Vector):Float {
    var h = height;
    var r = radius;
    var q = new Vector(Math.sqrt(p.x * p.x + p.z * p.z), p.y, 0);
    var k1 = new Vector(r, h, 0);
    var k2 = new Vector(r, -h, 0);
    var ca = k1.y - k2.y;
    var cb = k2.x - k1.x;
    var cc = k1.x * k2.y - k2.x * k1.y;
    var x = q.x;
    var y = q.y;
    var d1 = Math.max(x * k1.y - y * k1.x, x * k2.y - y * k2.x) / ca;
    var d2 = Math.sqrt(x * x + y * y);
    var s = (y > k1.y) ? 1.0 : (y < k2.y ? -1.0 : 0.0);
    var d = Math.max(d1, -d2) * s;
    return d;
  }
}
