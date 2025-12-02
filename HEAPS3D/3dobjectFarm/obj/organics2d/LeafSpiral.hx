package obj.organics2d;

import h3d.Vector;

class LeafSpiral {
  public static var color = new Vector(0.35, 0.9, 0.55);
  public static inline var turns = 2.5;
  public static inline var width = 0.18;

  public static inline function distance(p:Vector):Float {
    var ang = Math.atan2(p.z, p.x);
    var r = Math.sqrt(p.x * p.x + p.z * p.z);
    var target = 0.25 + 0.2 * (ang / (Math.PI * 2.0) * turns);
    var leaf = Math.abs(r - target) - width;
    var vein = Math.abs(p.z) * 0.1;
    return leaf + vein;
  }
}

class LeafSpiralShader extends BaseRaymarchShader {
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

        // 2D Leaf Spiral on face
        var turns = 2.5;
        var width = 0.18;
        var ang = atan(dy / dx);
        var r = sqrt(dx * dx + dy * dy);
        var target = 0.25 + 0.2 * (ang / (3.14159265 * 2.0) * turns);
        var leaf = abs(r - target) - width;
        var vein = abs(dy) * 0.1;
        var spiral2D = leaf + vein;

        if (spiral2D < 0.0) {
          col = vec3(0.35, 0.9, 0.55); // Light green
        }
      }

      return vec4(box3D, col.x, col.y, col.z);
    }
  };
}
