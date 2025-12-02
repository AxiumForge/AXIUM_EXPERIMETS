package obj.derivates;

import h3d.Vector;

class ShellCylinder {
  public static var color = new Vector(0.25, 0.8, 0.9);
  public static var radius = 0.55;
  public static var halfHeight = 0.7;
  public static var thickness = 0.08;
  public static var center = new Vector(-2.0, -0.1, -0.9);

  public static inline function distance(p:Vector):Float {
    var outer = sdCyl(p, radius, halfHeight);
    var inner = sdCyl(p, radius - thickness, halfHeight - thickness);
    return Math.max(outer, -inner);
  }

  static inline function sdCyl(p:Vector, r:Float, h:Float):Float {
    var dx = Math.sqrt(p.x * p.x + p.z * p.z) - r;
    var dy = Math.abs(p.y) - h;
    var ax = Math.max(dx, 0.0);
    var ay = Math.max(dy, 0.0);
    var outside = Math.sqrt(ax * ax + ay * ay);
    var inside = Math.min(Math.max(dx, dy), 0.0);
    return outside + inside;
  }
}

class ShellCylinderShader extends BaseRaymarchShader {
  static var SRC = {
    function sdCyl(p:Vec3, r:Float, h:Float):Float {
      var d = vec2(length(vec2(p.x, p.z)) - r, abs(p.y) - h);
      return min(max(d.x, d.y), 0.0) + length(max(d, vec2(0.0, 0.0)));
    }

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var r = 0.45;
      var h = 0.5;
      var t = 0.08;
      var outer = sdCyl(pr, r, h);
      var inner = sdCyl(pr, r - t, h - t);
      var dist = max(outer, -inner);
      var col = vec3(0.5, 0.9, 0.8);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
