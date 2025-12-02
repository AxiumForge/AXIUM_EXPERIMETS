package obj._3dOrganic;

import h3d.Vector;

class UndulatingPlane {
  public static inline var color = new Vector(0.8, 0.9, 0.95);
  public static inline var normal = new Vector(0, 1, 0);
  public static inline var offset = -1.0;
  public static inline var amp = 0.25;
  public static inline var freq = 1.2;

  public static inline function distance(p:Vector, time:Float):Float {
    var wave = Math.sin(p.x * freq + time * 0.8) * amp + Math.cos(p.z * freq * 0.8 + time * 0.6) * amp * 0.6;
    return p.x * normal.x + p.y * normal.y + p.z * normal.z + offset + wave;
  }
}

class UndulatingPlaneShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var offset = -1.0;
      var amp = 0.25;
      var freq = 1.2;

      var wave = sin(pr.x * freq + time * 0.8) * amp + cos(pr.z * freq * 0.8 + time * 0.6) * amp * 0.6;
      var dist = pr.y + offset + wave;

      var col = vec3(0.8, 0.9, 0.95);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
