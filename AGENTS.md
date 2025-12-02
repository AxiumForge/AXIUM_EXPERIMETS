# Repository Guidelines

## Project Structure & Module Organization
- `docs/` holds scene notes and reference snippets for both engines (`docs/lovr3dscene.md`, `docs/heaps3dscene.md`).
- `LOVR3D/` is for runnable LÖVR prototypes (Lua + GLSL-style shaders). Drop `main.lua` here when iterating.
- `HEAPS3D/` is for Heaps/Haxe builds (HXSL shaders + OpenGL backend). Keep Haxe sources and build config alongside generated artifacts.

## Build, Test, and Development Commands
- LÖVR: from `LOVR3D/`, run `lovr .` to launch the current `main.lua` scene. Use `LOVR_WINDOW_WIDTH/HEIGHT` env vars if you need a fixed viewport.
- Heaps: once you add a `build.hxml`, use `haxe build.hxml` to compile. For a quick dev loop, target HashLink (`-hl bin/main.hl`) and run `hl bin/main.hl`.
- Shader tweaks: regenerate any embedded shader strings after edits to keep Haxe/Lua sources in sync with the documented snippets.

## Coding Style & Naming Conventions
- Haxe: two-space indentation; `UpperCamelCase` for classes, `camelCase` for methods/fields; keep HXSL uniforms prefixed with `u_` only when the engine requires it.
- Lua (LÖVR): two-space indentation; `snake_case` for locals and functions; prefer module-level `local` bindings over globals.
- Shaders: keep helper SDF functions (`sdBox`, `sdCapsule`, `opSmoothUnion`) reused across variants; comment non-obvious math.

## Testing Guidelines
- No automated test harness yet; rely on interactive runs. For Lua, smoke-test with `lovr .` and verify FPS and visuals match the expected hard-surface + organic link scene. For Haxe, run the HL target and confirm the postprocess fullscreen pass renders without artifacts.
- When adding features, include a minimal repro scene in `LOVR3D/` or `HEAPS3D/` and note expected output in the PR description.

## Commit & Pull Request Guidelines
- Commits: short imperative subject lines (e.g., `Add smooth union link shader`), grouped by logical change.
- PRs: include a concise summary, linked issues (if any), and before/after screenshots or a short screen capture of the render. Mention platform (OS, GPU/API) and steps to run (`lovr .`, `haxe build.hxml` + `hl bin/main.hl`) so reviewers can reproduce.
