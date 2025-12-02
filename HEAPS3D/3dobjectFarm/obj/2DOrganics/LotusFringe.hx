package obj._2DOrganics;

import h3d.Vector;

class LotusFringe {
  public static inline var color = new Vector(0.85, 0.75, 0.3);
  public static inline var petals = 12;
  public static inline var baseR = 0.3;
  public static inline var tipR = 0.7;

  public static inline function distance(p:Vector):Float {
    var ang = Math.atan2(p.z, p.x);
    var r = Math.sqrt(p.x * p.x + p.z * p.z);
    var sector = Math.PI * 2.0 / petals;
    var a = ((ang % sector) + sector) % sector - sector * 0.5;
    var k = Math.cos(a);
    var target = baseR + (tipR - baseR) * k;
    return r - target;
  }
}

class LotusFringeShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var petals = 12.0;
      var baseR = 0.3;
      var tipR = 0.7;
      var ang = atan(pr.z / pr.x);
      var r = length(pr.xz);
      var sector = 3.14159265 * 2.0 / petals;
      var a = mod(mod(ang, sector) + sector, sector) - sector * 0.5;
      var k = cos(a);
      var target = baseR + (tipR - baseR) * k;
      var dist = r - target;
      var col = vec3(0.85, 0.75, 0.3);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
