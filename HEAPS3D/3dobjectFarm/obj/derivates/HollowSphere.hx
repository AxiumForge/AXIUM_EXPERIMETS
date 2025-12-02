package obj.derivates;

import h3d.Vector;

class HollowSphere {
  public static var color = new Vector(0.8, 0.3, 0.7);
  public static var outerRadius = 0.8;
  public static var thickness = 0.12;
  public static var center = new Vector(-1.6, 0.1, 0.0);

  public static inline function distance(p:Vector):Float {
    var d = p.length();
    var inner = outerRadius - thickness;
    return Math.abs(d - outerRadius) - thickness * 0.5 + Math.min(d - inner, 0.0);
  }
}

class HollowSphereShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = abs(length(pr) - 0.65) - 0.12;
      var col = vec3(0.8, 0.3, 0.7);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
