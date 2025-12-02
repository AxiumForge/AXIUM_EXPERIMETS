package obj.organics2d;

import h3d.Vector;

class SpiralVine {
  public static var color = new Vector(0.25, 0.8, 0.55);
  public static inline var turns = 3.0;
  public static inline var thickness = 0.12;

  public static inline function distance(p:Vector):Float {
    var angle = Math.atan2(p.z, p.x);
    var radius = Math.sqrt(p.x * p.x + p.z * p.z);
    var spiral = angle / (Math.PI * 2.0) * turns;
    var targetR = 0.4 + 0.15 * spiral;
    return Math.abs(radius - targetR) - thickness;
  }
}

class SpiralVineShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      // 3D box surface
      var boxHalf = vec3(1.0, 1.0, 0.04);
      var local = p;
      var d = abs(local) - boxHalf;
      var box3D = max(max(d.x, d.y), d.z);

      var col = vec3(0.3, 0.3, 0.3);
      var onFrontFace = abs(local.z - boxHalf.z) < 0.05;

      if (onFrontFace) {
        var dx = local.x;
        var dy = local.y;

        // 2D Spiral Vine on face
        var turns = 3.0;
        var thickness = 0.12;
        var angle = atan(dy / dx);
        var radius = sqrt(dx * dx + dy * dy);
        var spiral = angle / (3.14159265 * 2.0) * turns;
        var targetR = 0.4 + 0.15 * spiral;
        var vine2D = abs(radius - targetR) - thickness;

        if (vine2D < 0.0) {
          col = vec3(0.25, 0.8, 0.55); // Teal
        }
      }

      return vec4(box3D, col.x, col.y, col.z);
    }
  };
}
