package obj.organics2d;

import h3d.Vector;

class LotusFringe {
  public static var color = new Vector(0.85, 0.75, 0.3);
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
      // 3D box surface
      var boxHalf = vec3(1.0, 1.0, 0.04);
      var local = p;
      var d = abs(local) - boxHalf;
      var box3D = max(max(d.x, d.y), d.z);

      var col = vec3(0.3, 0.3, 0.3);
      var onFrontFace = abs(local.z - boxHalf.z) < 0.05;

      if (onFrontFace) {
        var dx = local.x;
        var dy = local.y;

        // 2D Lotus Fringe on face
        var petals = 12.0;
        var baseR = 0.3;
        var tipR = 0.7;
        var ang = atan(dy / dx);
        var r = sqrt(dx * dx + dy * dy);
        var sector = 3.14159265 * 2.0 / petals;
        var a = mod(mod(ang, sector) + sector, sector) - sector * 0.5;
        var k = cos(a);
        var target = baseR + (tipR - baseR) * k;
        var lotus2D = r - target;

        if (lotus2D < 0.0) {
          col = vec3(0.85, 0.75, 0.3); // Gold
        }
      }

      return vec4(box3D, col.x, col.y, col.z);
    }
  };
}
