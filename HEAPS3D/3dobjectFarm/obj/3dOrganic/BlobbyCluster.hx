package obj._3dOrganic;

import h3d.Vector;

class BlobbyCluster {
  class Object {
    public static inline var color = new Vector(0.4, 0.85, 0.6);
    public static inline var offsets = [
      new Vector(0.0, 0.0, 0.0),
      new Vector(0.5, 0.2, -0.3),
      new Vector(-0.4, 0.35, 0.4)
    ];
    public static inline var radii = [0.6, 0.45, 0.4];

    public static function distance(p:Vector):Float {
      var d = 1e5;
      for (i in 0...offsets.length) {
        var op = new Vector(p.x - offsets[i].x, p.y - offsets[i].y, p.z - offsets[i].z);
        var sd = op.length() - radii[i];
        if (sd < d) d = sd;
      }
      return d;
    }
  }

  class Shader extends BaseRaymarchShader {
    static var SRC = {
      @param var time : Float;

      function map(p:Vec3):Vec4 {
        var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
        var d = 1e5;

        // First sphere
        var d0 = length(pr - vec3(0.0, 0.0, 0.0)) - 0.6;
        d = min(d, d0);

        // Second sphere
        var d1 = length(pr - vec3(0.5, 0.2, -0.3)) - 0.45;
        d = min(d, d1);

        // Third sphere
        var d2 = length(pr - vec3(-0.4, 0.35, 0.4)) - 0.4;
        d = min(d, d2);

        var col = vec3(0.4, 0.85, 0.6);
        return vec4(d, col.x, col.y, col.z);
      }
    }
  }
}
