package obj._2DOrganics;

import h3d.Vector;

class FlowerPetalRing {
  class Object {
    public static inline var color = new Vector(0.9, 0.5, 0.75);
    public static inline var petals = 8;
    public static inline var inner = 0.2;
    public static inline var outer = 0.6;

    public static inline function distance(p:Vector):Float {
      var angle = Math.atan2(p.z, p.x);
      var radius = Math.sqrt(p.x * p.x + p.z * p.z);
      var sector = Math.PI * 2.0 / petals;
      var a = ((angle % sector) + sector) % sector - sector * 0.5;
      var petalR = inner + (outer - inner) * Math.cos(a);
      return radius - petalR;
    }
  }

  class Shader extends BaseRaymarchShader {
    static var SRC = {
      @param var time : Float;

      function map(p:Vec3):Vec4 {
        var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
        var petals = 8.0;
        var inner = 0.2;
        var outer = 0.6;
        var angle = atan(pr.z / pr.x);
        var radius = length(pr.xz);
        var sector = 3.14159265 * 2.0 / petals;
        var a = mod(mod(angle, sector) + sector, sector) - sector * 0.5;
        var petalR = inner + (outer - inner) * cos(a);
        var dist = radius - petalR;
        var col = vec3(0.9, 0.5, 0.75);
        return vec4(dist, col.x, col.y, col.z);
      }
    }
  }
}
