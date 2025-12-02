# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AXIUM_EXPERIMENTS is a dual-engine 3D graphics experimentation repository focused on **SDF (Signed Distance Field) raymarching** - NOT traditional mesh/polygon rendering.

**CRITICAL: This project uses mathematical distance functions to define geometry, NOT meshes or vertices.**

The project maintains parallel SDF implementations in LÖVR (Lua/GLSL) and Heaps (Haxe/HXSL) to explore:
- Procedural geometry via signed distance functions
- Sphere tracing/raymarching rendering techniques
- Smooth blending between hard surface and organic forms (impossible with traditional meshes)
- Cross-platform SDF shader development

## Repository Structure

- `LOVR3D/` - LÖVR engine prototypes (Lua + GLSL shaders)
  - `3dscenesdf/main.lua` - Runnable LÖVR scene with SDF raymarching
- `HEAPS3D/` - Heaps/Haxe engine implementations (HXSL shaders + OpenGL backend)
  - `3dscenesdf/` - Heaps scene with Main.hx, SDFLinkShader.hx, and build config
  - `3dscenesdf/bin/` - Compiled HashLink binaries
- `docs/` - Scene documentation and reference snippets
  - `lovr3dscene.md` - LÖVR implementation notes
  - `heaps3dscene.md` - Heaps implementation notes
- `AGENTS.md` - Repository guidelines and conventions

## Build and Run Commands

### LÖVR (Lua)
```bash
cd LOVR3D/3dscenesdf
lovr .
```
- Use environment variables `LOVR_WINDOW_WIDTH` and `LOVR_WINDOW_HEIGHT` for fixed viewport sizes
- Shader code is embedded as Lua strings in `main.lua`

### Heaps (Haxe + HashLink)
```bash
cd HEAPS3D/3dscenesdf
haxe build.hxml
hl bin/main.hl
```
- Compilation targets HashLink (`-hl bin/main.hl`)
- Requires `heaps` and `hlsdl` libraries
- OpenGL backend via SDL

## Architecture

### SDF Raymarching Fundamentals

**This is NOT mesh rendering.** Geometry is defined mathematically via distance functions:
- No vertices, no triangles, no UV mapping
- Scene defined entirely in the `map(vec3 p) -> float` function
- Distance returned = shortest distance from point `p` to nearest surface
- Rendering via sphere tracing: marching rays through the distance field until hitting a surface (distance < epsilon)

### Dual-Engine SDF Scene Implementation
Both engines implement identical procedural scenes:
- **Hard surfaces**: Two boxes defined by `sdBox()` SDF primitive (analytical distance to box surface)
- **Organic connector**: Capsule defined by `sdCapsule()` SDF (analytical distance to capsule surface)
- **Smooth blending**: `opSmoothUnion()` creates organic transitions (impossible with mesh CSG)
- **Raymarching loop**: 128-step sphere tracing with 0.0005 epsilon threshold, max distance 20.0
- **Lighting**: Normals calculated via gradient of distance field (`calcNormal()`), not vertex normals

### Shader Architecture (Fullscreen Raymarching)

**Rendering approach**: Every pixel traces its own ray through the SDF scene
- **LÖVR**: Fragment shader uses `gl_FragCoord` for fullscreen raymarching
  - Renders to a simple quad via `lovr.graphics.plane()` (quad is just a canvas, NOT the geometry)
  - All geometry computation happens in fragment shader per-pixel
- **Heaps**: HXSL `ScreenShader` with `ScreenFx` for fullscreen postprocess pass
  - Uses `calculatedUV` from base class for screen coordinates
  - Same principle: fullscreen pass, all geometry computed per-pixel

**Core SDF Functions** (keep synchronized across engines):
- `sdBox(p, b)` - returns signed distance to box surface
- `sdCapsule(p, a, b, r)` - returns signed distance to capsule surface
- `opSmoothUnion(d1, d2, k)` - blends two distance fields smoothly
- `map(p)` - THE scene definition function: combines all primitives, returns distance to nearest surface
- `raymarch(ro, rd)` - sphere tracing algorithm: steps along ray until `map(p) < epsilon`
- `calcNormal(p)` - computes surface normal via central differences of `map()` (NOT vertex normals)

**Coloring**: X-position based heuristic to distinguish hard (gray-blue) vs organic (orange) regions

### Uniform Management
- LÖVR: `shader:send('u_time', t)` and `shader:send('u_resolution', {w, h})`
- Heaps: Direct property assignment `sdf.time = t` and `sdf.resolution.set(w, h)`

## Code Style

### Haxe
- Two-space indentation
- `UpperCamelCase` for classes (`Main`, `SDFLinkShader`)
- `camelCase` for methods/fields
- HXSL uniforms prefixed with `u_` only when required by engine conventions

### Lua (LÖVR)
- Two-space indentation
- `snake_case` for locals and functions
- Prefer module-level `local` bindings over globals
- Shader code embedded as multiline strings

### Shaders (GLSL/HXSL)
- Comment non-obvious mathematical operations
- Keep SDF helper functions reusable across variants
- Group related functions with section comments (e.g., `// --------- SDF helpers ---------`)

## Testing and Development

- No automated test harness
- **LÖVR smoke test**: Run `lovr .` and verify FPS, visuals match expected hard-surface + organic link scene
- **Heaps smoke test**: Compile with `haxe build.hxml`, run `hl bin/main.hl`, confirm fullscreen pass renders without artifacts
- Include minimal repro scenes in PRs with expected output description

## SDF Development Workflow

**Remember: You are editing mathematical distance functions, not mesh geometry.**

1. Edit SDF functions in shader code (LÖVR: embedded string in main.lua, Heaps: SDFLinkShader.hx)
2. Modify `map()` function to change scene geometry
3. Test visually by running the scene
4. **Keep SDF primitives synchronized** between LÖVR (GLSL) and Heaps (HXSL) implementations
5. Reference `docs/` markdown files for implementation notes

**Adding new primitives**: Implement new `sdXXX()` functions returning signed distance to surface. See [Inigo Quilez's SDF reference](https://iquilezles.org/articles/distfunctions/) for standard primitives.

## Known Conventions

- Both engines render the same scene for 1:1 visual comparison
- Animation uses `sin(time * 0.5) * 0.1` for Y-axis pulsing effect
- Camera positioned at `(0, 0, 4)` with ray direction normalized from UV coordinates
- Background gradient based on UV Y-coordinate: `0.15 + 0.1 * uv.y` with blue tint
