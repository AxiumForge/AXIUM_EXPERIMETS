package obj.derivates;

import h3d.Vector;

class HoledPlane {
  public static inline var color = new Vector(0.9, 0.9, 0.95);
  public static inline var normal = new Vector(0, 1, 0);
  public static inline var offset = -1.0;
  public static inline var holeRadius = 0.5;
  public static inline var holeCenter = new Vector(0.0, 0.0, 0.0);

  public static inline function distance(p:Vector):Float {
    var planeD = p.x * normal.x + p.y * normal.y + p.z * normal.z + offset;
    var hole = Math.sqrt((p.x - holeCenter.x) * (p.x - holeCenter.x) + (p.z - holeCenter.z) * (p.z - holeCenter.z)) - holeRadius;
    return Math.max(planeD, -hole); // carve circular hole out of plane
  }
}
