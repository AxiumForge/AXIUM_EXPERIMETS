package obj.sdfTextures;

import h3d.Vector;

class LayeredScene {
  public static var color = new Vector(0.5, 0.5, 0.5);
}

class LayeredSceneShader extends BaseRaymarchShader {
  static var SRC = {
    // Returns vec4(distance, r, g, b) where rgb = (0,0,0) means "no pattern - discard in fragment()"
    function map(p:Vec3):Vec4 {
      var boxHalf = vec3(1.5, 1.5, 0.04);

      // Background sun sphere
      var sunCenter = vec3(0.0, 2.0, -3.0);
      var sunRadius = 0.8;
      var sunDist = length(p - sunCenter) - sunRadius;

      // Layer 1: Base box at z=0
      var local1 = p - vec3(0.0, 0.0, 0.0);
      var d1 = abs(local1) - boxHalf;
      var box1 = max(max(d1.x, d1.y), d1.z);

      // Layer 2: Tree box at z=0.3
      var local2 = p - vec3(0.0, 0.0, 0.3);
      var boxHalf2 = vec3(1.5, 1.5, 0.12);
      var d2 = abs(local2) - boxHalf2;
      var box2 = max(max(d2.x, d2.y), d2.z);

      // Layer 3: Fence box at z=0.7
      var local3 = p - vec3(0.0, 0.0, 0.7);
      var boxHalf3 = vec3(1.5, 1.5, 0.15);
      var d3 = abs(local3) - boxHalf3;
      var box3 = max(max(d3.x, d3.y), d3.z);

      // Find closest surface - include ALL objects
      var minDist = min(min(min(box1, box2), box3), sunDist);

      // Default: no pattern (will be discarded)
      var col = vec3(0.0, 0.0, 0.0);

      // Sun sphere
      if (abs(minDist - sunDist) < 0.001) {
        col = vec3(1.0, 0.9, 0.3); // Bright yellow sun
      }

      // Layer 1: Red square on front face only
      else if (abs(minDist - box1) < 0.001) {
        var onFront1 = abs(local1.z - boxHalf.z) < 0.05;
        if (onFront1) {
          var d = abs(vec2(local1.x, local1.y)) - vec2(0.5, 0.5);
          var square = max(d.x, d.y);
          if (square < 0.0) {
            col = vec3(0.9, 0.2, 0.2); // Red square
          }
        }
      }

      // Layer 2: Christmas tree on front face only
      else if (abs(minDist - box2) < 0.001) {
        var onFront2 = abs(local2.z - boxHalf2.z) < 0.05;
        if (onFront2) {
          var tx = local2.x;
          var ty = local2.y - 0.3;
          var treeTop = ty + abs(tx) * 1.732 + 0.6;
          var d = abs(vec2(local2.x, local2.y + 0.4)) - vec2(0.12, 0.12);
          var trunk = max(d.x, d.y);

          if (treeTop < 0.0) {
            col = vec3(0.2, 0.7, 0.2); // Green tree
          }
          else if (trunk < 0.0) {
            col = vec3(0.4, 0.25, 0.1); // Brown trunk
          }
        }
      }

      // Layer 3: White fence on front face only, at bottom
      else if (abs(minDist - box3) < 0.001) {
        var onFront3 = abs(local3.z - boxHalf3.z) < 0.05;
        if (onFront3) {
          var spacing = 0.4;
          var px = mod(local3.x + 1.5, spacing) - spacing * 0.5;
          var py = local3.y + 1.0;
          var rect = max(abs(px) - 0.12, abs(py) - 0.5);
          var pointY = 0.35;
          var tipDist = (py - pointY) + abs(px) * 0.5;
          var picket = rect;
          if (py > pointY) {
            picket = max(tipDist, rect);
          }

          if (picket < 0.0) {
            col = vec3(0.9, 0.9, 0.85); // White fence
          }
        }
      }

      return vec4(minDist, col.x, col.y, col.z);
    }

    // Override fragment() to use alpha channel - alpha=0 for (0,0,0) colors
    function fragment() {
      var uv = calculatedUV * 2.0 - 1.0;
      uv.x *= resolution.x / resolution.y;

      var ro = cameraPos;
      var rd = normalize(cameraForward + uv.x * cameraRight + uv.y * cameraUp);

      var rm = raymarch(ro, rd);
      var p = rm.xyz;
      var tHit = rm.w;

      var col:Vec3;
      var alpha = 1.0;

      if (tHit > 0.0) {
        // Check if base color is (0,0,0) - if so, make transparent
        var scene = map(p);
        var baseColor = scene.yzw;
        if (baseColor.x == 0.0 && baseColor.y == 0.0 && baseColor.z == 0.0) {
          alpha = 0.0; // Transparent
          col = vec3(0.0, 0.0, 0.0);
        } else {
          col = shade(p, rd);
          alpha = 1.0; // Opaque
        }
      } else {
        var g = 0.12 + 0.12 * uv.y;
        col = vec3(g, g * 1.15, g * 1.4);
        alpha = 1.0;
      }

      output.color = vec4(col, alpha);
    }
  };
}

