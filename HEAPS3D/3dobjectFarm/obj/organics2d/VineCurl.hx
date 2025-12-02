package obj.organics2d;

import h3d.Vector;

class VineCurl {
  public static var color = new Vector(0.2, 0.75, 0.45);
  public static inline var thickness = 0.1;

  public static inline function distance(p:Vector):Float {
    var r = Math.sqrt(p.x * p.x + p.z * p.z);
    var a = Math.atan2(p.z, p.x);
    var target = 0.3 + 0.12 * a;
    return Math.abs(r - target) - thickness;
  }
}

class VineCurlShader extends BaseRaymarchShader {
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

        // 2D Vine Curl on face
        var thickness = 0.1;
        var r = sqrt(dx * dx + dy * dy);
        var a = atan(dy / dx);
        var target = 0.3 + 0.12 * a;
        var curl2D = abs(r - target) - thickness;

        if (curl2D < 0.0) {
          col = vec3(0.2, 0.75, 0.45); // Dark green
        }
      }

      return vec4(box3D, col.x, col.y, col.z);
    }
  };
}
