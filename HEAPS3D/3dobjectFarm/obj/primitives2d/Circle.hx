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
      // 3D box (thin card/panel) - this is the surface
      var boxHalf = vec3(1.0, 1.0, 0.04);
      var boxCenter = vec3(0.0, 0.0, 0.0);

      // Transform to box local space
      var local = p - boxCenter;

      // Box SDF
      var d = abs(local) - boxHalf;
      var box3D = max(max(d.x, d.y), d.z);

      // Color based on 2D pattern
      var col = vec3(0.3, 0.3, 0.3); // Default box surface color (gray)

      // Only on front face (z ≈ boxHalf.z) - larger epsilon to catch raymarch samples
      var onFrontFace = abs(local.z - boxHalf.z) < 0.05;

      if (onFrontFace) {
        // Project onto face coordinate system (XY on the face)
        var dx = local.x;
        var dy = local.y;

        // 2D Circle SDF on the face itself
        var radius = 0.8;
        var circle2D = sqrt(dx * dx + dy * dy) - radius;

        if (circle2D < 0.0) {
          // Inside 2D circle on box surface - use circle color
          col = vec3(0.2, 0.8, 0.9); // Cyan circle
        }
      }

      // Raymarch the 3D box, colored by 2D pattern
      return vec4(box3D, col.x, col.y, col.z);
    }
  };
}
