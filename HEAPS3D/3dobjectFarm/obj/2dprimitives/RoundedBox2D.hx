package obj.primitives2d;

import h3d.Vector;

class RoundedBox2D {
  public static var color = new Vector(0.65, 0.7, 0.2);
  public static var halfExtents = new Vector(0.8, 0.0, 0.5);
  public static var radius = 0.15;
  public static var center = new Vector(0.0, 0.0, 0.0);

  public static inline function distance(p:Vector):Float {
    var qx = Math.abs(p.x) - (halfExtents.x - radius);
    var qz = Math.abs(p.z) - (halfExtents.z - radius);
    var ax = Math.max(qx, 0.0);
    var az = Math.max(qz, 0.0);
    return Math.sqrt(ax * ax + az * az) - radius + Math.min(Math.max(qx, qz), 0.0);
  }
}

class RoundedBox2DShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var halfExtents = vec2(0.8, 0.5);
      var radius = 0.15;
      var q = vec2(abs(pr.x) - (halfExtents.x - radius), abs(pr.z) - (halfExtents.y - radius));
      var dist = length(max(q, vec2(0.0, 0.0))) - radius + min(max(q.x, q.y), 0.0);
      var col = vec3(0.65, 0.7, 0.2);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
