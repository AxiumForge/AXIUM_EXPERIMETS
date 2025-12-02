package obj.primitives;

import h3d.Vector;

class Sphere {
  public static var color = new Vector(0.2, 0.7, 1.0);
  public static var radius = 0.55;
  public static var center = new Vector(-1.4, 0.0, 0.0);

  public static inline function distance(p:Vector):Float {
    return p.length() - radius;
  }
}

class SphereShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = length(pr) - 0.6;
      var col = vec3(0.2, 0.7, 1.0);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
