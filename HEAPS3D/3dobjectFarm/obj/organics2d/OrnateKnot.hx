package obj.organics2d;

import h3d.Vector;

class OrnateKnot {
  public static var color = new Vector(0.8, 0.55, 0.2);
  public static inline var radius = 0.45;
  public static inline var thickness = 0.12;

  public static inline function distance(p:Vector):Float {
    var u = p.x;
    var v = p.z;
    var r = Math.sqrt(u * u + v * v);
    var theta = Math.atan2(v, u);
    var knot = radius + 0.1 * Math.sin(3.0 * theta);
    return Math.abs(r - knot) - thickness;
  }
}

class OrnateKnotShader extends BaseRaymarchShader {
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

        // 2D Ornate Knot on face
        var radius = 0.45;
        var thickness = 0.12;
        var r = sqrt(dx * dx + dy * dy);
        var theta = atan(dy / dx);
        var knot = radius + 0.1 * sin(3.0 * theta);
        var knot2D = abs(r - knot) - thickness;

        if (knot2D < 0.0) {
          col = vec3(0.8, 0.55, 0.2); // Orange-brown
        }
      }

      return vec4(box3D, col.x, col.y, col.z);
    }
  };
}
