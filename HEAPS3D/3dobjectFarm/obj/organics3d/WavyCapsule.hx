package obj.organics3d;

import h3d.Vector;

class WavyCapsule {
  public static var color = new Vector(0.95, 0.5, 0.35);
  public static var a = new Vector(-0.6, -0.5, 0.8);
  public static var b = new Vector(0.6, 0.6, 0.8);
  public static inline var radius = 0.25;
  public static inline var amp = 0.08;
  public static inline var freq = 4.0;

  public static inline function distance(p:Vector, time:Float):Float {
    var pa = new Vector(p.x - a.x, p.y - a.y, p.z - a.z);
    var ba = new Vector(b.x - a.x, b.y - a.y, b.z - a.z);
    var h = clamp((pa.x * ba.x + pa.y * ba.y + pa.z * ba.z) / (ba.x * ba.x + ba.y * ba.y + ba.z * ba.z), 0.0, 1.0);
    var dx = pa.x - ba.x * h;
    var dy = pa.y - ba.y * h;
    var dz = pa.z - ba.z * h;
    var base = Math.sqrt(dx * dx + dy * dy + dz * dz) - radius;
    var wave = Math.sin(h * freq + time * 1.2) * amp;
    return base + wave;
  }

  static inline function clamp(v:Float, lo:Float, hi:Float):Float {
    return v < lo ? lo : (v > hi ? hi : v);
  }
}

class WavyCapsuleShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var a = vec3(-0.6, -0.5, 0.8);
      var b = vec3(0.6, 0.6, 0.8);
      var r = 0.25;
      var amp = 0.08;
      var freq = 4.0;

      var pa = pr - a;
      var ba = b - a;
      var h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
      var base = length(pa - ba * h) - r;
      var wave = sin(h * freq + time * 1.2) * amp;
      var dist = base + wave;

      var col = vec3(0.95, 0.5, 0.35);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
