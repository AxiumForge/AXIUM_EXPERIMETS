package obj._2DOrganics;

import h3d.Vector;

class FlowerPetalRing {
  public static inline var color = new Vector(0.9, 0.5, 0.75);
  public static inline var petals = 8;
  public static inline var inner = 0.2;
  public static inline var outer = 0.6;

  public static inline function distance(p:Vector):Float {
    var angle = Math.atan2(p.z, p.x);
    var radius = Math.sqrt(p.x * p.x + p.z * p.z);
    var sector = Math.PI * 2.0 / petals;
    var a = ((angle % sector) + sector) % sector - sector * 0.5;
    var petalR = inner + (outer - inner) * Math.cos(a);
    return radius - petalR;
  }
}
