package obj._3dOrganic;

import h3d.Vector;

class UndulatingPlane {
  public static inline var color = new Vector(0.8, 0.9, 0.95);
  public static inline var normal = new Vector(0, 1, 0);
  public static inline var offset = -1.0;
  public static inline var amp = 0.25;
  public static inline var freq = 1.2;

  public static inline function distance(p:Vector, time:Float):Float {
    var wave = Math.sin(p.x * freq + time * 0.8) * amp + Math.cos(p.z * freq * 0.8 + time * 0.6) * amp * 0.6;
    return p.x * normal.x + p.y * normal.y + p.z * normal.z + offset + wave;
  }
}
