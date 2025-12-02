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
      var pr = rotateY(p, time * 0.7);
      var turns = 3.0;
      var thickness = 0.12;
      var angle = atan(pr.z / pr.x);
      var radius = length(pr.xz);
      var spiral = angle / (3.14159265 * 2.0) * turns;
      var targetR = 0.4 + 0.15 * spiral;
      var dist = abs(radius - targetR) - thickness;
      var col = vec3(0.25, 0.8, 0.55);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
