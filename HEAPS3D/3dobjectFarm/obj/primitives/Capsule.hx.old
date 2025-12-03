package obj.primitives;

import h3d.Vector;

class Capsule {
  public static var color = new Vector(0.9, 0.6, 0.25);
  public static var a = new Vector(-0.4, -0.4, -1.1);
  public static var b = new Vector(0.6, 0.5, -1.1);
  public static var radius = 0.22;

  public static inline function distance(p:Vector):Float {
    var paX = p.x - a.x;
    var paY = p.y - a.y;
    var paZ = p.z - a.z;
    var baX = b.x - a.x;
    var baY = b.y - a.y;
    var baZ = b.z - a.z;
    var baLen2 = baX * baX + baY * baY + baZ * baZ;
    var h = clamp((paX * baX + paY * baY + paZ * baZ) / baLen2, 0.0, 1.0);
    var dx = paX - baX * h;
    var dy = paY - baY * h;
    var dz = paZ - baZ * h;
    return Math.sqrt(dx * dx + dy * dy + dz * dz) - radius;
  }

  static inline function clamp(v:Float, lo:Float, hi:Float):Float {
    return v < lo ? lo : (v > hi ? hi : v);
  }
}

class CapsuleShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var a = vec3(0.0, -0.4, 0.0);
      var b = vec3(0.0, 0.4, 0.0);
      var r = 0.3;
      var pa = pr - a;
      var ba = b - a;
      var h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
      var dist = length(pa - ba * h) - r;
      var col = vec3(0.3, 0.85, 0.4);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
