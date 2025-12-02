package obj.organics3d;

import h3d.Vector;

class MeltedBox {
  public static var color = new Vector(0.7, 0.4, 0.3);
  public static var halfExtents = new Vector(0.6, 0.4, 0.5);
  public static inline var melt = 0.18;

  public static inline function distance(p:Vector):Float {
    var qx = Math.abs(p.x) - halfExtents.x;
    var qy = Math.abs(p.y) - halfExtents.y;
    var qz = Math.abs(p.z) - halfExtents.z;
    var ax = Math.max(qx, 0.0);
    var ay = Math.max(qy, 0.0);
    var az = Math.max(qz, 0.0);
    var outside = Math.sqrt(ax * ax + ay * ay + az * az);
    var inside = Math.min(Math.max(qx, Math.max(qy, qz)), 0.0);
    var base = outside + inside;
    var blob = Math.sin((p.x + p.y + p.z) * 1.6) * melt;
    return base + blob;
  }
}

class MeltedBoxShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var halfExtents = vec3(0.6, 0.4, 0.5);
      var melt = 0.18;

      var q = abs(pr) - halfExtents;
      var base = length(max(q, vec3(0.0, 0.0, 0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);
      var blob = sin((pr.x + pr.y + pr.z) * 1.6) * melt;
      var dist = base + blob;

      var col = vec3(0.7, 0.4, 0.3);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
