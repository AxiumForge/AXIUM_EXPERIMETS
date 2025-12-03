package obj.primitives2d;

import h3d.Vector;

class Star implements AxObjectClass {
  public function new() {}

  public function shader():hxsl.Shader {
    return new StarShader();
  }

  public function object():PdfObject {
    return {
      name: "Star",
      sdf: { kind: "custom", params: {} },
      transform: { position: {x:0, y:0, z:0}, rotation: {x:0, y:0, z:0}, scale: {x:1, y:1, z:1} },
      material: {
        color: {r: 0.9, g: 0.8, b: 0.25, a: 1.0},
        roughness: 0.5,
        metallic: 0.0
      }
    };
  }
}

class StarShader extends BaseRaymarchShader {
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

        // 2D Star SDF on the face itself
        var innerRadius = 0.35;
        var outerRadius = 0.7;
        var points = 5.0;
        var ang = atan(dy / dx);
        if (dx < 0.0) ang += 3.14159265;
        var r = sqrt(dx * dx + dy * dy);
        var sector = 3.14159265 * 2.0 / points;
        var a = mod(ang, sector) - sector * 0.5;
        var edge = cos(a) * mix(outerRadius, innerRadius, step(abs(a), sector * 0.25));
        var star2D = r - edge;

        if (star2D < 0.0) {
          // Inside 2D star on surface - use yellow color
          col = vec3(0.9, 0.8, 0.25);
        }
      }

      // Raymarch the 3D box, colored by 2D pattern
      return vec4(box3D, col.x, col.y, col.z);
    }
  };
}
