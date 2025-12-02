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
      var boxSize = vec3(2.0, 2.0, 0.08);
      var dx = abs(p.x) - boxSize.x;
      var dy = abs(p.y) - boxSize.y;
      var dz = abs(p.z) - boxSize.z;
      var box3D = max(max(dx, dy), dz);

      // 2D Circle - defines the cutout/pattern on the box surface (z=0 plane)
      var radius = 0.8;
      var circle2D = length(vec2(p.x, p.y)) - radius;

      // Color based on 2D pattern
      var col = vec3(0.3, 0.3, 0.3); // Default box surface color (gray)

      // Only show circle on front face (positive Z side facing camera)
      if (p.z > 0.0 && circle2D < 0.0) {
        // Inside 2D circle cutout on front face - use circle color
        col = vec3(0.2, 0.8, 0.9); // Cyan circle
      }

      // Raymarch the 3D box, colored by 2D pattern
      return vec4(box3D, col.x, col.y, col.z);
    }
  };
}
