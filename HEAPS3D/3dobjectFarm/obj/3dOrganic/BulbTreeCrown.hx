package obj._3dOrganic;

import h3d.Vector;

class BulbTreeCrown {
  public static inline var color = new Vector(0.45, 0.85, 0.35);
  public static inline var trunkHeight = 0.4;
  public static inline var trunkRadius = 0.15;
  public static inline var bulbRadius = 0.55;
  public static inline var center = new Vector(0.0, -0.2, -1.0);

  public static inline function distance(p:Vector):Float {
    // trunk cylinder
    var dx = Math.sqrt(p.x * p.x + p.z * p.z) - trunkRadius;
    var dy = Math.abs(p.y + trunkHeight * 0.5) - trunkHeight * 0.5;
    var ax = Math.max(dx, 0.0);
    var ay = Math.max(dy, 0.0);
    var trunk = Math.sqrt(ax * ax + ay * ay) + Math.min(Math.max(dx, dy), 0.0);

    // crown as union of spheres
    var crownCenter = new Vector(0, trunkHeight * 0.5 + bulbRadius * 0.6, 0);
    var d1 = new Vector(p.x - crownCenter.x, p.y - crownCenter.y, p.z - crownCenter.z).length() - bulbRadius;
    var d2 = new Vector(p.x - (crownCenter.x + 0.3), p.y - (crownCenter.y + 0.15), p.z - crownCenter.z).length() - bulbRadius * 0.8;
    var d3 = new Vector(p.x - (crownCenter.x - 0.25), p.y - (crownCenter.y + 0.2), p.z - (crownCenter.z + 0.25)).length() - bulbRadius * 0.7;

    return Math.min(trunk, Math.min(d1, Math.min(d2, d3)));
  }
}
