package obj._2DOrganics;

import h3d.Vector;

class SpiralVine {
  public static inline var color = new Vector(0.25, 0.8, 0.55);
  public static inline var turns = 3.0;
  public static inline var thickness = 0.12;

  public static inline function distance(p:Vector):Float {
    // use x,z as 2D plane
    var angle = Math.atan2(p.z, p.x);
    var radius = Math.sqrt(p.x * p.x + p.z * p.z);
    var spiral = angle / (Math.PI * 2.0) * turns;
    var targetR = 0.4 + 0.15 * spiral;
    return Math.abs(radius - targetR) - thickness;
  }
}
