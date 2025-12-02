package obj._3dOrganic;

import h3d.Vector;

class BlobbyCluster {
  public static inline var color = new Vector(0.4, 0.85, 0.6);
  public static inline var offsets = [
    new Vector(0.0, 0.0, 0.0),
    new Vector(0.5, 0.2, -0.3),
    new Vector(-0.4, 0.35, 0.4)
  ];
  public static inline var radii = [0.6, 0.45, 0.4];

  public static function distance(p:Vector):Float {
    var d = 1e5;
    for (i in 0...offsets.length) {
      var op = new Vector(p.x - offsets[i].x, p.y - offsets[i].y, p.z - offsets[i].z);
      var sd = op.length() - radii[i];
      if (sd < d) d = sd;
    }
    return d;
  }
}
