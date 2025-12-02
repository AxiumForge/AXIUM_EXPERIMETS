package obj.organics3d;

import h3d.Vector;

class BulbTreeCrown {
  public static var color = new Vector(0.45, 0.85, 0.35);
  public static inline var trunkHeight = 0.4;
  public static inline var trunkRadius = 0.15;
  public static inline var bulbRadius = 0.55;
  public static var center = new Vector(0.0, -0.2, -1.0);

  public static inline function distance(p:Vector):Float {
    // trunk cylinder
    var dx = Math.sqrt(p.x * p.x + p.z * p.z) - trunkRadius;
    var dy = Math.abs(p.y + trunkHeight * 0.5) - trunkHeight * 0.5;
    var ax = Math.max(dx, 0.0);
    var ay = Math.max(dy, 0.0);
    var trunk = Math.sqrt(ax * ax + ay * ay) + Math.min(Math.max(dx, dy), 0.0);

    // crown as union of spheres
    var crownCenter = new Vector(0, trunkHeight * 0.5 + bulbRadius * 0.6, 0);
    var d1 = new Vector(p.x - crownCenter.x, p.y - crownCenter.y, p.z - crownCenter.z).length() - bulbRadius;
    var d2 = new Vector(p.x - (crownCenter.x + 0.3), p.y - (crownCenter.y + 0.15), p.z - crownCenter.z).length() - bulbRadius * 0.8;
    var d3 = new Vector(p.x - (crownCenter.x - 0.25), p.y - (crownCenter.y + 0.2), p.z - (crownCenter.z + 0.25)).length() - bulbRadius * 0.7;

    return Math.min(trunk, Math.min(d1, Math.min(d2, d3)));
  }
}

class BulbTreeCrownShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var trunkH = 0.4;
      var trunkR = 0.15;
      var bulbR = 0.55;

      var cyl = vec2(length(pr.xz) - trunkR, abs(pr.y + trunkH * 0.5) - trunkH * 0.5);
      var trunk = min(max(cyl.x, cyl.y), 0.0) + length(max(cyl, vec2(0.0, 0.0)));

      var crownCenter = vec3(0.0, trunkH * 0.5 + bulbR * 0.6, 0.0);
      var d1 = length(pr - crownCenter) - bulbR;
      var d2 = length(pr - (crownCenter + vec3(0.3, 0.15, 0.0))) - bulbR * 0.8;
      var d3 = length(pr - (crownCenter + vec3(-0.25, 0.2, 0.25))) - bulbR * 0.7;

      var dist = min(trunk, min(d1, min(d2, d3)));
      var col = vec3(0.45, 0.85, 0.35);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
