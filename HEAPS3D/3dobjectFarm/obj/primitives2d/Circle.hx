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
      var pr = rotateY(p, time * 0.7);
      var radius = 0.6;
      var dist = length(vec2(pr.x, pr.z)) - radius;
      var col = vec3(0.2, 0.8, 0.9);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
