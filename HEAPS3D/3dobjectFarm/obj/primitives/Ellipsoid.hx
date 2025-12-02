package obj.primitives;

import h3d.Vector;

class Ellipsoid {
  public static var color = new Vector(0.15, 0.9, 0.6);
  public static var radii = new Vector(0.9, 0.5, 0.35);
  public static var center = new Vector(0.0, -0.4, -1.6);

  public static inline function distance(p:Vector):Float {
    var k0 = new Vector(p.x / radii.x, p.y / radii.y, p.z / radii.z);
    var k1 = new Vector(p.x / (radii.x * radii.x), p.y / (radii.y * radii.y), p.z / (radii.z * radii.z));
    var s = 1.0 / Math.sqrt(k0.x * k0.x + k0.y * k0.y + k0.z * k0.z);
    return (p.x * k1.x + p.y * k1.y + p.z * k1.z) * s - 1.0;
  }
}

class EllipsoidShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var r = vec3(0.7, 0.4, 0.5);
      var k0 = length(pr / r);
      var k1 = length(pr / (r * r));
      var dist = k0 * (k0 - 1.0) / k1;
      var col = vec3(0.9, 0.75, 0.3);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
