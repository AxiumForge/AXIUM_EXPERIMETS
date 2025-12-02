package obj.primitives2d;

import h3d.Vector;

class Star {
  public static var color = new Vector(0.9, 0.8, 0.25);
  public static var innerRadius = 0.35;
  public static var outerRadius = 0.7;
  public static var points = 5;

  public static inline function distance(p:Vector):Float {
    var ang = Math.atan2(p.z, p.x);
    var r = Math.sqrt(p.x * p.x + p.z * p.z);
    var sector = Math.PI * 2.0 / points;
    var a = ((ang % sector) + sector) % sector - sector * 0.5;
    var edge = Math.cos(a) * mix(outerRadius, innerRadius, step(Math.abs(a), sector * 0.25));
    return r - edge;
  }

  static inline function mix(a:Float, b:Float, t:Float):Float {
    return a + (b - a) * t;
  }

  static inline function step(x:Float, edge:Float):Float {
    return x < edge ? 1.0 : 0.0;
  }
}

class StarShader extends BaseRaymarchShader {
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

        // 2D Star SDF on the face itself
        var innerRadius = 0.35;
        var outerRadius = 0.7;
        var points = 5.0;
        var ang = atan(dy / dx);
        if (dx < 0.0) ang += 3.14159265;
        var r = sqrt(dx * dx + dy * dy);
        var sector = 3.14159265 * 2.0 / points;
        var a = mod(ang, sector) - sector * 0.5;
        var edge = cos(a) * mix(outerRadius, innerRadius, step(abs(a), sector * 0.25));
        var star2D = r - edge;

        if (star2D < 0.0) {
          // Inside 2D star on surface - use yellow color
          col = vec3(0.9, 0.8, 0.25);
        }
      }

      // Raymarch the 3D box, colored by 2D pattern
      return vec4(box3D, col.x, col.y, col.z);
    }
  };
}
