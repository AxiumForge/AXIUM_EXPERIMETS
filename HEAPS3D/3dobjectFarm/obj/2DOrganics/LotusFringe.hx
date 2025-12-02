package obj._2DOrganics;

import h3d.Vector;

class LotusFringe {
  public static inline var color = new Vector(0.85, 0.75, 0.3);
  public static inline var petals = 12;
  public static inline var baseR = 0.3;
  public static inline var tipR = 0.7;

  public static inline function distance(p:Vector):Float {
    var ang = Math.atan2(p.z, p.x);
    var r = Math.sqrt(p.x * p.x + p.z * p.z);
    var sector = Math.PI * 2.0 / petals;
    var a = ((ang % sector) + sector) % sector - sector * 0.5;
    var k = Math.cos(a);
    var target = baseR + (tipR - baseR) * k;
    return r - target;
  }
}
