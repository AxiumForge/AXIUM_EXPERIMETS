package obj.organics3d;

import h3d.Vector;

class SoftSphereWrap {
  public static var color = new Vector(0.75, 0.4, 0.9);
  public static inline var baseRadius = 0.7;
  public static inline var wobble = 0.12;
  public static inline var freq = 3.5;
  public static var center = new Vector(-1.2, 0.2, 0.0);

  public static inline function distance(p:Vector, time:Float):Float {
    var d = p.length();
    var ripple = Math.sin((p.x + p.y + p.z) * freq + time * 1.5) * wobble;
    return d - (baseRadius + ripple);
  }
}

class SoftSphereWrapShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var baseRadius = 0.7;
      var wobble = 0.12;
      var freq = 3.5;

      var d = length(pr);
      var ripple = sin((pr.x + pr.y + pr.z) * freq + time * 1.5) * wobble;
      var dist = d - (baseRadius + ripple);

      var col = vec3(0.75, 0.4, 0.9);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
