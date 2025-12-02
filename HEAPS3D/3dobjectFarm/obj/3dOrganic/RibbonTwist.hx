package obj._3dOrganic;

import h3d.Vector;

class RibbonTwist {
  public static inline var color = new Vector(0.3, 0.8, 0.95);
  public static inline var width = 0.2;
  public static inline var thickness = 0.12;
  public static inline var length = 1.4;
  public static inline var twist = 3.2;
  public static inline var center = new Vector(0.0, 0.0, 0.0);

  public static inline function distance(p:Vector):Float {
    var ang = twist * p.y;
    var ca = Math.cos(ang);
    var sa = Math.sin(ang);
    var rx = p.x * ca - p.z * sa;
    var rz = p.x * sa + p.z * ca;
    var qx = Math.abs(rx) - width;
    var qy = Math.abs(p.y) - length * 0.5;
    var qz = Math.abs(rz) - thickness;
    var ax = Math.max(qx, 0.0);
    var ay = Math.max(qy, 0.0);
    var az = Math.max(qz, 0.0);
    var outside = Math.sqrt(ax * ax + ay * ay + az * az);
    var inside = Math.min(Math.max(qx, Math.max(qy, qz)), 0.0);
    return outside + inside;
  }
}

class RibbonTwistShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var width = 0.2;
      var thickness = 0.12;
      var length = 1.4;
      var twist = 3.2;

      var ang = twist * pr.y;
      var ca = cos(ang);
      var sa = sin(ang);
      var rx = pr.x * ca - pr.z * sa;
      var rz = pr.x * sa + pr.z * ca;

      var q = vec3(abs(rx) - width, abs(pr.y) - length * 0.5, abs(rz) - thickness);
      var dist = length(max(q, vec3(0.0, 0.0, 0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);

      var col = vec3(0.3, 0.8, 0.95);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
