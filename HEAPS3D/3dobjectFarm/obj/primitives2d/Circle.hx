package obj.primitives2d;

import h3d.Vector;

class Circle implements AxObjectClass {
  public function new() {}

  public function shader():hxsl.Shader {
    return new CircleShader();
  }

  public function object():PdfObject {
    return {
      name: "Circle",
      sdf: { kind: "custom", params: {} },
      transform: { position: {x:0, y:0, z:0}, rotation: {x:0, y:0, z:0}, scale: {x:1, y:1, z:1} },
      material: {
        color: {r: 0.2, g: 0.8, b: 0.9, a: 1.0},
        roughness: 0.5,
        metallic: 0.0
      }
    };
  }
}

class CircleShader extends BaseRaymarchShader {
  static var SRC = {
    function map(p:Vec3):Vec4 {
      // 3D box (thin card/panel) - this is the surface
      var boxHalf = vec3(1.0, 1.0, 0.04);
      var boxCenter = vec3(0.0, 0.0, 0.0);

      // Transform to box local space
      var local = p - boxCenter;

      // Box SDF
      var d = abs(local) - boxHalf;
      var box3D = max(max(d.x, d.y), d.z);

      // Color based on 2D pattern
      var col = vec3(0.3, 0.3, 0.3); // Default box surface color (gray)

      // Project onto face coordinate system (XY on the face)
      var dx = local.x;
      var dy = local.y;
      var dist2D = sqrt(dx * dx + dy * dy);

      // Front face (z ≈ boxHalf.z)
      var onFrontFace = abs(local.z - boxHalf.z) < 0.05;

      // Back face (z ≈ -boxHalf.z)
      var onBackFace = abs(local.z + boxHalf.z) < 0.05;

      if (onFrontFace) {
        // Single cyan circle on front
        var radius = 0.8;
        var circle2D = dist2D - radius;

        if (circle2D < 0.0) {
          col = vec3(0.2, 0.8, 0.9); // Cyan circle
        }
      }
      else if (onBackFace) {
        // 3 concentric circles on back - check from largest to smallest
        var radius1 = 0.8; // Outermost
        var radius2 = 0.55; // Middle
        var radius3 = 0.3; // Innermost

        if (dist2D < radius1) {
          col = vec3(0.9, 0.3, 0.3); // Red outer ring
        }
        if (dist2D < radius2) {
          col = vec3(0.3, 0.9, 0.3); // Green middle ring
        }
        if (dist2D < radius3) {
          col = vec3(0.3, 0.3, 0.9); // Blue center circle
        }
      }

      // Raymarch the 3D box, colored by 2D pattern
      return vec4(box3D, col.x, col.y, col.z);
    }
  };
}
