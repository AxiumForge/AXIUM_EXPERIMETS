# AxObjectClass Definition (v0.3)

Consolidated spec that replaces v0.2 and the refactor plan. Goal: one simple AxObject pattern plus one universal scene shader. Use this as the authority for new and migrated code.

## Core rules
- One class per AxObject file, named after the object, `implements AxObjectClass`.
- Two methods only: `shader():hxsl.Shader` and `object():PdfObject`.
- No shader classes in AxObject files. All shader code lives in engine libs.
- `shader()` returns the universal scene shader and only sets uniforms; `object()` returns structured data.

## Engine-side architecture
- Single renderer: `SdfSceneShader` (scene-based raymarcher). No per-primitive shaders.
- Shared libs: `AxRaymarchLib` (SDF ops, scene traversal), `AxMaterialLib` (lighting/material lookup), `AxDefaultShaders` (only `sdfSceneShader()` factory).
- Runtime sends scene data as uniforms/buffers (primitive types/params, material ids, transforms).

## AxObject pattern (v0.3)
```haxe
class Box implements AxObjectClass {
  public var color = vec3(0.65, 0.35, 0.55);
  public var alpha = 1.0;

  public function new() {}

  public function shader():hxsl.Shader {
    var s = AxDefaultShaders.sdfSceneShader();
    var scene = cast(s, SdfSceneShader);
    scene.uObjectColor = color;
    scene.uObjectAlpha = alpha;
    return s;
  }

  public function object():PdfObject {
    return {
      name: "Box",
      prims: [
        { primType: PRIM_BOX, params: [0.5, 0.35, 0.45], materialId: 0, transformId: 0 }
      ],
      transforms: [
        { position: {x:0, y:0, z:0}, rotation: {x:0, y:0, z:0}, scale: {x:1, y:1, z:1} }
      ],
      materials: [
        { color: {r:0.65, g:0.35, b:0.55, a:1.0}, roughness:0.5, metallic:0.0 }
      ]
    };
  }
}
```
Notes:
- `shader()` never defines or embeds SRC; it just configures the shared shader.
- `object()` is pure data; match the PdfObject schema used by the engine (primitives, transforms, materials).

## PdfObject expectations
- Must encode all geometry/material/transform data; no inline code.
- Primitives are an array with type + params + links to material/transform entries.
- Materials define color/roughness/metallic/alpha; transforms define position/rotation/scale.

## Do / Do not
- Do: keep AxObject files tiny, deterministic, and data-driven.
- Do: extend engine libs (SdfSceneShader, AxRaymarchLib, AxMaterialLib) when new math/features are needed.
- Do not: add `*ShaderImpl` per object; do not parse or compile HXSL inside AxObject files.

## Migration checklist (from v0.2)
1) Remove per-primitive shader classes and factories.
2) Introduce `SdfSceneShader` and update `AxDefaultShaders` to only expose it.
3) Move all SDF/math/material code into engine libs.
4) Update every AxObject: `shader()` returns the scene shader with uniforms; `object()` returns full PdfObject data.
5) Ensure runtime uploads primitive/material/transform buffers for the scene shader.
