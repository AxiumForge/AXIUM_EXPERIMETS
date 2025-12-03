package obj.primitives;

import h3d.Vector;

class Plane {
  public static var color = new Vector(0.9, 0.9, 0.95);
  public static var normal = new Vector(0, 1, 0);
  public static var offset = -0.9;

  public static inline function distance(p:Vector):Float {
    return p.x * normal.x + p.y * normal.y + p.z * normal.z + offset;
  }
}

class PlaneShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = pr.y + 1.0;
      var col = vec3(0.6, 0.6, 0.7);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
