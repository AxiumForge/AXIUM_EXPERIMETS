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
      var pr = rotateY(p, time * 0.7);
      var turns = 2.5;
      var width = 0.18;
      var ang = atan(pr.z / pr.x);
      var r = length(pr.xz);
      var target = 0.25 + 0.2 * (ang / (3.14159265 * 2.0) * turns);
      var leaf = abs(r - target) - width;
      var vein = abs(pr.z) * 0.1;
      var dist = leaf + vein;
      var col = vec3(0.35, 0.9, 0.55);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
