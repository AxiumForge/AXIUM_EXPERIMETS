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
      var pr = rotateY(p, time * 0.7);
      var leafWidth = 0.35;
      var leafLength = 0.8;
      var gap = 0.1;
      var dLeft = leafSDF(vec2(pr.x + gap, pr.z), leafWidth, leafLength);
      var dRight = leafSDF(vec2(-pr.x + gap, pr.z), leafWidth, leafLength);
      var dist = min(dLeft, dRight);
      var col = vec3(0.3, 0.9, 0.5);
      return vec4(dist, col.x, col.y, col.z);
    }
  };
}
