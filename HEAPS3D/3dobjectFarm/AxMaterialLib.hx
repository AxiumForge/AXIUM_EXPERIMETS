package;

import h3d.shader.ScreenShader;

/**
  AxMaterialLib - Material and shading functions

  Contains lighting, normal calculation, and shading logic.
  Used by SdfSceneShader for rendering primitives.
**/
class AxMaterialLib extends ScreenShader {
  static var SRC = {

    @param var time : Float;

    // Calculate surface normal via central differences
    function calcNormal(p:Vec3, mapFunc:Vec3->Float):Vec3 {
      var e = vec2(0.001, 0.0);
      var dx = mapFunc(p + vec3(e.x, e.y, e.y)) - mapFunc(p - vec3(e.x, e.y, e.y));
      var dy = mapFunc(p + vec3(e.y, e.x, e.y)) - mapFunc(p - vec3(e.y, e.x, e.y));
      var dz = mapFunc(p + vec3(e.y, e.y, e.x)) - mapFunc(p - vec3(e.y, e.y, e.x));
      return normalize(vec3(dx, dy, dz));
    }

    // Shade a point with diffuse + rim + ambient lighting
    function shade(p:Vec3, rd:Vec3, baseColor:Vec3, normal:Vec3):Vec3 {
      var lightDir = normalize(vec3(0.6, 1.2, -0.7));
      var diff = max(dot(normal, lightDir), 0.0);
      var rim = pow(1.0 - max(dot(normal, -rd), 0.0), 2.2);

      var col = baseColor * (0.2 + 0.8 * diff);
      col += rim * vec3(0.6, 0.8, 1.0);
      col += vec3(0.05, 0.06, 0.07);
      return col;
    }
  };
}
