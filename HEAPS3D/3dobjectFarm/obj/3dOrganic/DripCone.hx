package obj._3dOrganic;

import h3d.Vector;

class DripCone {
  public static inline var color = new Vector(0.85, 0.55, 0.4);
  public static inline var height = 1.1;
  public static inline var radius = 0.7;
  public static inline var dripRadius = 0.2;

  public static inline function distance(p:Vector):Float {
    // upright cone
    var q = new Vector(Math.sqrt(p.x * p.x + p.z * p.z), p.y, 0);
    var tip = new Vector(0, height * 0.5, 0);
    var k = new Vector(radius / height, 1.0, 0);
    var c = new Vector(q.x, q.y + height * 0.5, 0);
    var dCone = Math.max(q.y * k.y - q.x * k.x, q.y) - height * 0.5;

    // hanging drip below tip
    var dp = new Vector(p.x, p.y + height * 0.2, p.z);
    var dDrip = dp.length() - dripRadius;

    return Math.min(dCone, dDrip);
  }
}

class DripConeShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var height = 1.1;
      var radius = 0.7;
      var dripRadius = 0.2;

      var q = vec2(length(pr.xz), pr.y);
      var k = vec2(radius / height, 1.0);
      var dCone = max(q.y * k.y - q.x * k.x, q.y) - height * 0.5;

      var dDrip = length(pr + vec3(0.0, height * 0.2, 0.0)) - dripRadius;

      var dist = min(dCone, dDrip);
      var col = vec3(0.85, 0.55, 0.4);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
