package obj.primitives;

import h3d.Vector;

class Box {
  public static var color = new Vector(0.65, 0.35, 0.55);
  public static var halfExtents = new Vector(0.5, 0.35, 0.45);

  public static inline function distance(p:Vector):Float {
    var qx = Math.abs(p.x) - halfExtents.x;
    var qy = Math.abs(p.y) - halfExtents.y;
    var qz = Math.abs(p.z) - halfExtents.z;
    var ax = Math.max(qx, 0.0);
    var ay = Math.max(qy, 0.0);
    var az = Math.max(qz, 0.0);
    var outside = Math.sqrt(ax * ax + ay * ay + az * az);
    var inside = Math.min(Math.max(qx, Math.max(qy, qz)), 0.0);
    return outside + inside;
  }
}

class BoxShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var b = vec3(0.5, 0.35, 0.45);
      var q = abs(pr) - b;
      var dist = length(max(q, vec3(0.0, 0.0, 0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);
      var col = vec3(0.65, 0.35, 0.55);
      return vec4(dist, col.x, col.y, col.z);
    }

    // Override fragment() to add alpha transparency control
    function fragment() {
      var uv = calculatedUV * 2.0 - 1.0;
      uv.x *= resolution.x / resolution.y;

      var ro = cameraPos;
      var rd = normalize(cameraForward + uv.x * cameraRight + uv.y * cameraUp);

      var rm = raymarch(ro, rd);
      var p = rm.xyz;
      var tHit = rm.w;

      var g = 0.12 + 0.12 * uv.y;
      var background = vec3(g, g * 1.15, g * 1.4);

      var col:Vec3;
      var alpha = alphaControl; // Use alpha control for the box

      if (tHit > 0.0) {
        var shaded = shade(p, rd);
        // Blend shaded object against background using alpha, keeping output alpha opaque to avoid dimming
        col = mix(background, shaded, alpha);
      } else {
        col = background;
      }

      output.color = vec4(col, 1.0);
    }
  };
}
