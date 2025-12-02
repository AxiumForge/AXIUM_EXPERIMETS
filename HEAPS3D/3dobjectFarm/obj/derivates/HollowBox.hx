package obj.derivates;

import h3d.Vector;

class HollowBox {
  public static var color = new Vector(0.55, 0.75, 0.3);
  public static var halfExtents = new Vector(0.7, 0.45, 0.5);
  public static var thickness = 0.08;
  public static var center = new Vector(0.2, -0.2, 1.2);

  public static inline function distance(p:Vector):Float {
    var outer = sdBox(p, halfExtents);
    var inner = sdBox(p, new Vector(halfExtents.x - thickness, halfExtents.y - thickness, halfExtents.z - thickness));
    return Math.max(outer, -inner);
  }

  static inline function sdBox(p:Vector, b:Vector):Float {
    var qx = Math.abs(p.x) - b.x;
    var qy = Math.abs(p.y) - b.y;
    var qz = Math.abs(p.z) - b.z;
    var ax = Math.max(qx, 0.0);
    var ay = Math.max(qy, 0.0);
    var az = Math.max(qz, 0.0);
    var outside = Math.sqrt(ax * ax + ay * ay + az * az);
    var inside = Math.min(Math.max(qx, Math.max(qy, qz)), 0.0);
    return outside + inside;
  }
}

class HollowBoxShader extends BaseRaymarchShader {
  static var SRC = {
    function sdBox(p:Vec3, b:Vec3):Float {
      var q = abs(p) - b;
      return length(max(q, vec3(0.0, 0.0, 0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);
    }

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var b = vec3(0.5, 0.4, 0.45);
      var t = 0.08;
      var outer = sdBox(pr, b);
      var inner = sdBox(pr, b - vec3(t, t, t));
      var dist = max(outer, -inner);
      var col = vec3(0.7, 0.5, 0.9);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
