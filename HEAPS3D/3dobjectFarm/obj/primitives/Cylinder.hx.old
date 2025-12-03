package obj.primitives;

import h3d.Vector;

class Cylinder {
  public static var color = new Vector(0.3, 0.8, 0.8);
  public static var radius = 0.4;
  public static var halfHeight = 0.65;
  public static var center = new Vector(2.1, 0.0, -0.3);

  public static inline function distance(p:Vector):Float {
    var qx = Math.sqrt(p.x * p.x + p.z * p.z) - radius;
    var qy = Math.abs(p.y) - halfHeight;
    var ax = Math.max(qx, 0.0);
    var ay = Math.max(qy, 0.0);
    var outside = Math.sqrt(ax * ax + ay * ay);
    var inside = Math.min(Math.max(qx, qy), 0.0);
    return outside + inside;
  }
}

class CylinderShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var h = 0.5;
      var r = 0.4;
      var d = vec2(length(vec2(pr.x, pr.z)) - r, abs(pr.y) - h);
      var dist = min(max(d.x, d.y), 0.0) + length(max(d, vec2(0.0, 0.0)));
      var col = vec3(0.4, 0.8, 0.9);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
