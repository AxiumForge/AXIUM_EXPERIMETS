package obj.primitives2d;

import h3d.Vector;

class Heart {
  public static var color = new Vector(0.9, 0.3, 0.35);
  public static var scale = 1.0;

  public static inline function distance(p:Vector):Float {
    var x = p.x * scale;
    var y = p.z * scale;
    var a = x * x + y * y - 1.0;
    return (a * a * a - x * x * y * y * y) / (scale * 3.0);
  }
}

class HeartShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      // No rotation - 2D shape static in XZ plane (like flat paper)

      // 2D Heart shape in XZ plane
      var scale = 1.0;
      var x = p.x * scale;
      var z = p.z * scale;
      var a = x * x + z * z - 1.0;
      var shape2D = (a * a * a - x * x * z * z * z) / (scale * 3.0);

      // Thin plane in Y (paper-like but visible)
      var thickness = 0.1;
      var planeY = abs(p.y) - thickness;

      // Intersection: both must be negative (inside both shapes)
      var dist = max(shape2D, planeY);

      var col = vec3(0.9, 0.3, 0.35);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
