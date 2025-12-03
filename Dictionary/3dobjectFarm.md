# HEAPS3D/3dobjectFarm (Heaps raymarch SDF gallery)
- Formål: Referenceprojekt der viser 39 SDF-former i Heaps/Haxe med raymarching, dynamisk shader-swap og et UI-panel til formvalg og alpha-blend.
- Hurtig kørsel: `cd HEAPS3D/3dobjectFarm && haxe build.hxml && hl bin/main.hl`.
- Flags: `--<shape>` vælger en specifik form (lowercase navn fra ShapeCatalog); `--sc` for screenshot, `--seq`/`--sc-seq` til sekvenser.
- Output: Screenshots lander i `HEAPS3D/sc` (se `Screenshot.defaultDirFromProgramPath`).
- Nøglefiler: `Main.hx` (render loop, kamera, screenshots), `ShapeCatalog.hx` (registrerer forme og shader-instanser), `ShapePanel.hx` (UI + input), `SDFObjectFarmShader.hx`/`SdfSceneShader.hx` (raymarch shaders), `AxDefaultShaders.hx` + `AxObjectClass.hx` (konfigurerbare standardmaterialer/objektbaser), `Shapes.hx` + `obj/` (selve forme).
- Test/sanity: `./test_all_shapes.sh` kører alle former med screenshots (timeout-baseret check).
- Kendte begrænsninger: Alpha er blend-workaround (ikke rigtig transparent); enkelte forme (cone/pyramid/quarter/holed/hollow-varianter) kan glitch’e eller miste hul; UI-panel kan hoppe ved vinduesstørrelsesændring.
