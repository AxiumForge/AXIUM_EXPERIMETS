package obj.primitives2d;

import h3d.Vector;

class Heart {
  public static var color = new Vector(0.9, 0.3, 0.35);
  public static var scale = 1.0;

  public static inline function distance(p:Vector):Float {
    var x = p.x * scale;
    var y = p.z * scale;
    var a = x * x + y * y - 1.0;
    return (a * a * a - x * x * y * y * y) / (scale * 3.0);
  }
}

class HeartShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateY(p, time * 0.7);

      // 2D Heart shape in XZ plane
      var scale = 1.0;
      var x = pr.x * scale;
      var z = pr.z * scale;
      var a = x * x + z * z - 1.0;
      var shape2D = (a * a * a - x * x * z * z * z) / (scale * 3.0);

      // Extrude 2D shape to thin 3D volume (standard SDF extrusion)
      var thickness = 0.05;
      var w = vec2(shape2D, abs(pr.y) - thickness);
      var dist = min(max(w.x, w.y), 0.0) + length(max(w, vec2(0.0)));

      var col = vec3(0.9, 0.3, 0.35);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
