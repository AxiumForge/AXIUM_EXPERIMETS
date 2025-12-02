package obj.organics2d;

import h3d.Vector;

class FlowerPetalRing {
  public static var color = new Vector(0.9, 0.5, 0.75);
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

class FlowerPetalRingShader extends BaseRaymarchShader {
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

        // 2D Flower Petal Ring on face
        var petals = 8.0;
        var inner = 0.2;
        var outer = 0.6;
        var angle = atan(dy / dx);
        var radius = sqrt(dx * dx + dy * dy);
        var sector = 3.14159265 * 2.0 / petals;
        var a = mod(mod(angle, sector) + sector, sector) - sector * 0.5;
        var petalR = inner + (outer - inner) * cos(a);
        var flower2D = radius - petalR;

        if (flower2D < 0.0) {
          col = vec3(0.9, 0.5, 0.75); // Pink
        }
      }

      return vec4(box3D, col.x, col.y, col.z);
    }
  };
}
