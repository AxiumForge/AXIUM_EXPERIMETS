package obj._3dOrganic;

import h3d.Vector;

class BubbleCrown {
  class Object {
    public static inline var color = new Vector(0.7, 0.95, 0.9);
    public static inline var baseRadius = 0.4;
    public static inline var lift = 0.5;

    public static inline function distance(p:Vector):Float {
      var d0 = new Vector(p.x, p.y - lift, p.z).length() - baseRadius;
      var d1 = new Vector(p.x + 0.3, p.y - lift + 0.15, p.z).length() - baseRadius * 0.8;
      var d2 = new Vector(p.x - 0.25, p.y - lift + 0.1, p.z + 0.3).length() - baseRadius * 0.7;
      var d3 = new Vector(p.x, p.y - lift + 0.2, p.z - 0.25).length() - baseRadius * 0.65;
      return Math.min(Math.min(d0, d1), Math.min(d2, d3));
    }
  }

  class Shader extends BaseRaymarchShader {
    static var SRC = {
      @param var time : Float;

      function map(p:Vec3):Vec4 {
        var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
        var baseRadius = 0.4;
        var lift = 0.5;
        var d0 = length(vec3(pr.x, pr.y - lift, pr.z)) - baseRadius;
        var d1 = length(vec3(pr.x + 0.3, pr.y - lift + 0.15, pr.z)) - baseRadius * 0.8;
        var d2 = length(vec3(pr.x - 0.25, pr.y - lift + 0.1, pr.z + 0.3)) - baseRadius * 0.7;
        var d3 = length(vec3(pr.x, pr.y - lift + 0.2, pr.z - 0.25)) - baseRadius * 0.65;
        var dist = min(min(d0, d1), min(d2, d3));
        var col = vec3(0.7, 0.95, 0.9);
        return vec4(dist, col.x, col.y, col.z);
      }
    }
  }
}
