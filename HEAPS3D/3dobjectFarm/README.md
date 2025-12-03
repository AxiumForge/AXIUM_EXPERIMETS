# 3dobjectFarm (Heaps)

Raymarchet SDF-galleri med 39 former, dynamisk shader-swap og UI-sidepanel til valg/alpha.

## Kørsel
- Build: `haxe build.hxml`
- Run: `hl bin/main.hl`
- Flags: `--sc` (screenshot), `--seq`/`--sc-seq` (frame-sekvens), `--<shape>` for en specifik form (navn i lowercase, fx `--torus`).
- Screenshots lander i `HEAPS3D/sc` (nuvarande sti fra `Screenshot.defaultDirFromProgramPath`).

## Controls
- Klik i panelet for valg; scroll i panelet med mouse wheel.
- `UP/DOWN` skifter form, `LEFT/RIGHT` ændrer alpha (workaround-blend i de fleste shaders).
- Mouse wheel i viewport: zoom; `F12` eller `P`: screenshot.

## Struktur
- `Main.hx` orchestrerer render loop, kamera, screenshots.
- `ShapeCatalog.hx` registrerer alle former og bygger shader-instanser.
- `ShapePanel.hx` UI-panel og input-håndtering.
- `AxDefaultShaders.hx` konfigurerbare standardshadere til AxObjectClass-former.
- `obj/` mapper indeholder forme (primitives, derivates, organics2d/3d).
- `test_all_shapes.sh` kører alle former med `--sc` (timeout-baseret sanity check).

## Kendte issues (spejl fra ISSUES)
- Cone/pyramid glitches under rotation; quarter/holed/hollow varianter viser ikke altid hul (alpha begrænset).
- DripCone/KnotTube m.fl. kan forsvinde i view; BulbTree mangler brun stamme; panel hop mellem vinduesstørrelser.
- Alpha er en blend-workaround (ikke rigtig transparent) for de fleste shaders.

## Roadmap (kort)
- Færdiggør AxObjectClass-migrering for alle former.
- Rigtig alpha-blending eller konsistent mix-workflow.
- Stabil UI-panel placering og bedre lys/animation toggles.

## Test
- Hurtig sanity: `./test_all_shapes.sh` (forventer PASS/timeout pr. form).
