package obj.primitives2d;

import h3d.Vector;

class Heart {
  public static var color = new Vector(0.9, 0.3, 0.35);
  public static var scale = 1.0;

  public static inline function distance(p:Vector):Float {
    var x = p.x * scale;
    var y = p.z * scale;
    var a = x * x + y * y - 1.0;
    return (a * a * a - x * x * y * y * y) / (scale * 3.0);
  }
}

class HeartShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var scale = 1.0;
      var x = pr.x * scale;
      var y = pr.z * scale;
      var a = x * x + y * y - 1.0;
      var dist = (a * a * a - x * x * y * y * y) / (scale * 3.0);
      var col = vec3(0.9, 0.3, 0.35);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
