package obj.primitives;

import h3d.Vector;

/**
  Box - Axis-aligned box primitive (AxObjectClass v0.1)

  This is the reference implementation for the AxObjectClass pattern.
  All future shapes should follow this structure.
**/
class Box implements AxObjectClass {

  public function new() {}

  public function shader():hxsl.Shader {
    return new BoxShader();
  }

  public function object():PdfObject {
    return {
      name: "Box",
      sdf: {
        kind: "sdBox",
        params: {
          halfExtents: {x: 0.5, y: 0.35, z: 0.45}
        }
      },
      transform: {
        position: {x: 0.0, y: 0.0, z: 0.0},
        rotation: {x: 0.0, y: 0.0, z: 0.0},
        scale: {x: 1.0, y: 1.0, z: 1.0}
      },
      material: {
        color: {r: 0.65, g: 0.35, b: 0.55, a: 1.0},
        roughness: 0.5,
        metallic: 0.0
      }
    };
  }
}

/**
  BoxShader - GPU raymarching shader for Box SDF

  Implements the signed distance function for an axis-aligned box.
  Extends BaseRaymarchShader for common raymarching/lighting logic.
**/
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
