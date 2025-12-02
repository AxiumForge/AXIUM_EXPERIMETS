package obj.primitives;

import h3d.Vector;

class Box {
  class Object {
    public static inline var color = new Vector(0.65, 0.35, 0.55);
    public static inline var halfExtents = new Vector(0.5, 0.35, 0.45);
    public static inline var center = new Vector(-2.2, -0.1, 0.3);

    public static inline function distance(p:Vector):Float {
      var qx = Math.abs(p.x) - halfExtents.x;
      var qy = Math.abs(p.y) - halfExtents.y;
      var qz = Math.abs(p.z) - halfExtents.z;
      var ax = Math.max(qx, 0.0);
      var ay = Math.max(qy, 0.0);
      var az = Math.max(qz, 0.0);
      var outside = Math.sqrt(ax * ax + ay * ay + az * az);
      var inside = Math.min(Math.max(qx, Math.max(qy, qz)), 0.0);
      return outside + inside;
    }
  }

  class Shader extends BaseRaymarchShader {
    static var SRC = {
      @param var time : Float;

      function map(p:Vec3):Vec4 {
        var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
        var b = vec3(0.5, 0.35, 0.45);
        var q = abs(pr) - b;
        var dist = length(max(q, vec3(0.0, 0.0, 0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);
        var col = vec3(0.65, 0.35, 0.55);
        return vec4(dist, col.x, col.y, col.z);
      }
    }
  }
}
