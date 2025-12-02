package obj.primitives2d;

import h3d.Vector;

class Star {
  public static var color = new Vector(0.9, 0.8, 0.25);
  public static var innerRadius = 0.35;
  public static var outerRadius = 0.7;
  public static var points = 5;

  public static inline function distance(p:Vector):Float {
    var ang = Math.atan2(p.z, p.x);
    var r = Math.sqrt(p.x * p.x + p.z * p.z);
    var sector = Math.PI * 2.0 / points;
    var a = ((ang % sector) + sector) % sector - sector * 0.5;
    var edge = Math.cos(a) * mix(outerRadius, innerRadius, step(Math.abs(a), sector * 0.25));
    return r - edge;
  }

  static inline function mix(a:Float, b:Float, t:Float):Float {
    return a + (b - a) * t;
  }

  static inline function step(x:Float, edge:Float):Float {
    return x < edge ? 1.0 : 0.0;
  }
}

class StarShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var innerRadius = 0.35;
      var outerRadius = 0.7;
      var points = 5.0;
      var ang = atan(pr.z / pr.x);
      if (pr.x < 0.0) ang += 3.14159265;
      var r = length(vec2(pr.x, pr.z));
      var sector = 3.14159265 * 2.0 / points;
      var a = mod(ang, sector) - sector * 0.5;
      var edge = cos(a) * mix(outerRadius, innerRadius, step(abs(a), sector * 0.25));
      var dist = r - edge;
      var col = vec3(0.9, 0.8, 0.25);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
