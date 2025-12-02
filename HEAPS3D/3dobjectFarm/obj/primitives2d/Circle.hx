package obj.primitives2d;

import h3d.Vector;

class Circle {
  public static var color = new Vector(0.2, 0.8, 0.9);
  public static var radius = 0.6;
  public static var center = new Vector(0.0, 0.0, 0.0);

  public static inline function distance(p:Vector):Float {
    var dx = p.x;
    var dz = p.z;
    return Math.sqrt(dx * dx + dz * dz) - radius;
  }
}

class CircleShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      // No rotation - 2D shape static in XZ plane (like flat paper)

      // 2D Circle in XZ plane
      var radius = 0.8;
      var shape2D = length(vec2(p.x, p.z)) - radius;

      // Thin plane in Y (paper-like but visible)
      var thickness = 0.1;
      var planeY = abs(p.y) - thickness;

      // Intersection: both must be negative (inside both shapes)
      var dist = max(shape2D, planeY);

      var col = vec3(0.2, 0.8, 0.9);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
