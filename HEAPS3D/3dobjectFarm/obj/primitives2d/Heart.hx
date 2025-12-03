package obj.primitives2d;

import h3d.Vector;

class Heart implements AxObjectClass {
  public function new() {}

  public function shader():hxsl.Shader {
    return new HeartShader();
  }

  public function object():PdfObject {
    return {
      name: "Heart",
      sdf: { kind: "custom", params: {} },
      transform: { position: {x:0, y:0, z:0}, rotation: {x:0, y:0, z:0}, scale: {x:1, y:1, z:1} },
      material: {
        color: {r: 0.9, g: 0.3, b: 0.35, a: 1.0},
        roughness: 0.5,
        metallic: 0.0
      }
    };
  }
}

class HeartShader extends BaseRaymarchShader {
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

      // Only on front face (z ≈ boxHalf.z)
      var onFrontFace = abs(local.z - boxHalf.z) < 0.05;

      if (onFrontFace) {
        // Project onto face coordinate system (XY on the face)
        var dx = local.x;
        var dy = local.y;

        // 2D Heart SDF on the face itself
        var scale = 1.0;
        var x = dx * scale;
        var y = dy * scale;
        var a = x * x + y * y - 1.0;
        var heart2D = (a * a * a - x * x * y * y * y) / (scale * 3.0);

        if (heart2D < 0.0) {
          // Inside 2D heart on box surface - use heart color
          col = vec3(0.9, 0.3, 0.35); // Red/pink heart
        }
      }

      // Raymarch the 3D box, colored by 2D pattern
      return vec4(box3D, col.x, col.y, col.z);
    }
  };
}
