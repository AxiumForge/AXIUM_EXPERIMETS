package obj.organics2d;

import h3d.Vector;

class LeafPair {
  public static var color = new Vector(0.3, 0.9, 0.5);
  public static inline var length = 0.8;
  public static inline var width = 0.35;
  public static inline var gap = 0.1;

  public static inline function distance(p:Vector):Float {
    var dLeft = leafSDF(new Vector(p.x + gap, p.z));
    var dRight = leafSDF(new Vector(-p.x + gap, p.z));
    return Math.min(dLeft, dRight);
  }

  static inline function leafSDF(p:Vector):Float {
    var qx = Math.abs(p.x) / width;
    var qy = p.y / length;
    var k = Math.max(qx + qy, qy);
    return k - 1.0;
  }
}

class LeafPairShader extends BaseRaymarchShader {
  static var SRC = {
    function leafSDF(p:Vec2, leafWidth:Float, leafLength:Float):Float {
      var qx = abs(p.x) / leafWidth;
      var qy = p.y / leafLength;
      var k = max(qx + qy, qy);
      return k - 1.0;
    }

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

        // 2D Leaf Pair on face
        var leafWidth = 0.35;
        var leafLength = 0.8;
        var gap = 0.1;
        var dLeft = leafSDF(vec2(dx + gap, dy), leafWidth, leafLength);
        var dRight = leafSDF(vec2(-dx + gap, dy), leafWidth, leafLength);
        var leaf2D = min(dLeft, dRight);

        if (leaf2D < 0.0) {
          col = vec3(0.3, 0.9, 0.5); // Green
        }
      }

      return vec4(box3D, col.x, col.y, col.z);
    }
  };
}
