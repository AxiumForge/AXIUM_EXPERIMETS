package obj.primitives2d;

import h3d.Vector;

class Box2D {
  public static var color = new Vector(0.9, 0.4, 0.3);
  public static var halfExtents = new Vector(0.7, 0.0, 0.45);
  public static var center = new Vector(0.0, 0.0, 0.0);

  public static inline function distance(p:Vector):Float {
    var qx = Math.abs(p.x) - halfExtents.x;
    var qz = Math.abs(p.z) - halfExtents.z;
    var ax = Math.max(qx, 0.0);
    var az = Math.max(qz, 0.0);
    var outside = Math.sqrt(ax * ax + az * az);
    var inside = Math.min(Math.max(qx, qz), 0.0);
    return outside + inside;
  }
}

class Box2DShader extends BaseRaymarchShader {
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

      // Only on front face (z ≈ boxHalf.z)
      var onFrontFace = abs(local.z - boxHalf.z) < 0.05;

      if (onFrontFace) {
        // Project onto face coordinate system (XY on the face)
        var dx = local.x;
        var dy = local.y;

        // 2D Box SDF on the face itself
        var halfExtents = vec2(0.7, 0.45);
        var q = vec2(abs(dx) - halfExtents.x, abs(dy) - halfExtents.y);
        var outside = length(max(q, vec2(0.0, 0.0)));
        var inside = min(max(q.x, q.y), 0.0);
        var box2D = outside + inside;

        if (box2D < 0.0) {
          // Inside 2D box on surface - use orange color
          col = vec3(0.9, 0.4, 0.3);
        }
      }

      // Raymarch the 3D box, colored by 2D pattern
      return vec4(box3D, col.x, col.y, col.z);
    }
  };
}
