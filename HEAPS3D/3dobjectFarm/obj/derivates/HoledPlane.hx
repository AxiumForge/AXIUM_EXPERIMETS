package obj.derivates;

import h3d.Vector;

class HoledPlane {
  public static var color = new Vector(0.9, 0.9, 0.95);
  public static var normal = new Vector(0, 1, 0);
  public static var offset = -1.0;
  public static var holeRadius = 0.5;
  public static var holeCenter = new Vector(0.0, 0.0, 0.0);

  public static inline function distance(p:Vector):Float {
    var planeD = p.x * normal.x + p.y * normal.y + p.z * normal.z + offset;
    var hole = Math.sqrt((p.x - holeCenter.x) * (p.x - holeCenter.x) + (p.z - holeCenter.z) * (p.z - holeCenter.z)) - holeRadius;
    return Math.max(planeD, -hole);
  }
}

class HoledPlaneShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var planeD = pr.y + 1.0;
      var hole = length(vec2(pr.x, pr.z)) - 0.5;
      var dist = max(planeD, -hole);
      var col = vec3(0.65, 0.65, 0.75);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
