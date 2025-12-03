# AxObjectClass Refactor Document (v0.3)

**Transition to Unified Scene-Based Raymarcher Architecture**

Dette dokument er en *udvidelse og opdatering* af AxObjectClass Definition v0.2 fileciteturn4file0. Formålet er at give Claude en fuldstændig og utvetydig *refactor-plan*, så AxiumForge skifter fra:

❌ *Per-primitive shaders* (BoxShaderImpl, SphereShaderImpl, CapsuleShaderImpl …)

… til …

✅ *ÉN universel scene-baseret raymarch-shader* (SdfSceneShader), der kan tegne *uendeligt mange primitives*, sammensatte former, komplekse CSG/SDF-strukturer og objekter.

Det er ekstremt vigtigt, at Claude følger dette dokument *præcist*, da den gamle arkitektur fører til shader-eksplosion, lock-in og ubrugelig kompleksitet.

---

# 1. MÅL FOR DENNE REFACTOR

### 🎯 1. Én shader-type i hele engine-laget

* `SdfSceneShader` styrer AL rendering.
* Ingen objekt-specifikke shader-klasser længere.

### 🎯 2. AxObject-filer forbliver identiske i struktur

Hver AxObject skal fortsat have:

```haxe
public function shader():hxsl.Shader;
public function object():PdfObject;
```

Men `shader()` må nu KUN returnere en instans af `SdfSceneShader` og sætte uniforms.

### 🎯 3. AL geometri defineres som *data* i `PdfObject`

Dette betyder:

* primitives (sphere, box, capsule osv.) bliver entries i en array
* materialer defineres via materialIds
* transforms defineres via transform arrays

### 🎯 4. AL SDF-kode bor i engine-laget

* SDF helpers: `sdfSphere`, `sdfBox`, …
* Scene-composition: `sdfScene()`
* Raymarcher: `raymarchScene()`
* Materiale-funktioner: `shade()`
* Kamera/UV funktioner: `makeRayFromScreenCoord()`

AxObject-filer har INGEN shader-logic.

---

# 2. PROBLEMET I DEN GAMLE ARKITEKTUR

Den tidligere løsning brugte:

* 9+ shader-klasser (`BoxShaderImpl`, `SphereShaderImpl`, …)
* 9+ fabriksmetoder i `AxDefaultShaders`
* én shape per shader

### ❌ Konsekvenser:

* Umuligt at lave sammensatte objekter (bobletræer, robotter, figurer, scener)
* Shaderfiler vokser eksponentielt
* Claude bliver forvirret og laver nye shader-klasser hele tiden
* Ingen mulighed for smooth unions, blends, CSG eller flere primitives i samme objekt

Dette bryder AxObjectClass-filosofien.

---

# 3. DEN NYE ARKITEKTUR (DEN RIGTIGE)

## ⭐ 3.1 ÉN SCENE-SHADER

```haxe
class SdfSceneShader extends hxsl.Shader {
  static var SRC = {
    @:import AxRaymarchLib;    // sdfScene, sdfSphere, sdfBox …
    @:import AxMaterialLib;    // shade(), sdfNormal(), materialId → farve

    @param var uObjectColor : Vec3;
    @param var uObjectAlpha : Float;

    @fragment
    function fragment() {
      var ro = uCameraPos;
      var rd = makeRayFromScreenCoord();

      var hit = raymarchScene(ro, rd);

      if (hit.dist > uMaxDist) {
        out = vec4(0.0, 0.0, 0.0, 0.0);
        return;
      }

      var col = shade(hit.position, hit.matId);
      col *= uObjectColor;

      out = vec4(col, uObjectAlpha);
    }
  };
}
```

🚨 Dette er den **ENESTE** shader-klasse i hele engine-laget til SDF-rendering.

---

# 4. AxDefaultShaders (NY VERSION)

```haxe
class AxDefaultShaders {
  public static function sdfSceneShader():hxsl.Shader {
    return new SdfSceneShader();
  }
}
```

* Ingen `BoxShaderImpl`.
* Ingen `SphereShaderImpl`.
* KUN `sdfSceneShader()`.

---

# 5. AxRaymarchLib (ANSVAR)

Dette bibliotek indeholder:

* `sdfSphere`, `sdfBox`, `sdfCapsule`, … (funktioner baseret på matematisk distance field)
* `sdfScene()` → løkker gennem en liste af primitives sendt som uniforms
* `raymarchScene()`
* `makeRayFromScreenCoord()`

```haxe
function sdfScene(p:Vec3):SdfHit {
  var best : SdfHit;
  best.dist = 1e5;

  for (i in 0...uPrimCount) {
    var d = 0.0;
    if (uPrimType[i] == PRIM_SPHERE)
      d = sdfSphere(p, uPrimParam0[i].x);
    else if (uPrimType[i] == PRIM_BOX)
      d = sdfBox(p, uPrimParam0[i].xyz);

    if (d < best.dist) {
      best.dist = d;
      best.matId = uPrimMatId[i];
    }
  }
  return best;
}
```

Dette muliggør:

* uendelig mange primitives
* sammensatte figurer
* scener, ikke kun shapes

---

# 6. AxMaterialLib (ANSVAR)

```haxe
function shade(p:Vec3, matId:Int):Vec3 {
  // beregn normal
  // vælg materiale baseret på matId
  // returner farve
}
```

Objekter bestemmer farve/alpha via uniforms.

---

# 7. AxObject-filer (NY STRUKTUR – ENKEL OG REN)

Eksempel `Box.hx`:

```haxe
class Box implements AxObjectClass {
  public var color = vec3(1,0,0);
  public var alpha = 1.0;

  public function new() {}

  public function shader():hxsl.Shader {
    var s = AxDefaultShaders.sdfSceneShader();
    cast(s, SdfSceneShader).uObjectColor = color;
    cast(s, SdfSceneShader).uObjectAlpha = alpha;
    return s;
  }

  public function object():PdfObject {
    return {
      name: "Box",
      prims: [
        {
          primType: PRIM_BOX,
          params: [1,1,1],
          materialId: 1,
          transformId: 0
        }
      ],
      transforms: [...],
      materials: [...]
    };
  }
}
```

### ✔️ Farve per objekt

### ✔️ Alpha per objekt

### ✔️ Ingen shaderkode per objekt

### ✔️ 100% kompatibel med v0.2 reglerne

---

# 8. Hvad Claude SKAL gøre i refactoren

1. **Fjerne alle primitive-specifikke shader-klasser:**

   * `BoxShaderImpl`
   * `SphereShaderImpl`
   * `CapsuleShaderImpl`
   * osv.

2. **Fjerne alle fabriksmetoder til disse shaders.**

3. **Indføre følgende filer i engine-laget:**

   * `SdfSceneShader.hx`
   * `AxRaymarchLib.hx` (opdateret)
   * `AxMaterialLib.hx` (opdateret)
   * `AxDefaultShaders.hx` (kun én metode)

4. **Opdatere alle AxObject-filer til denne struktur:**

   * `shader()` → returnér `AxDefaultShaders.sdfSceneShader()`
   * sæt farve/alpha/materiale-uniforms
   * INGEN shaderkode

5. **Opdatere PdfObject til at kunne beskrive mange primitives**

   * `prims: []`
   * `materials: []`
   * `transforms: []`

6. **Opdatere engine-runtime til at sende uniforms/buffers for scenedata**

   * `uPrimType[]`
   * `uPrimParam0[]`
   * `uPrimMaterialId[]`
   * `uTransform[]`

---

# 9. HVORFOR DETTE ER DEN ENESTE RIGTIGE ARKITEKTUR

### 🔥 Fordi AxiumForge arbejder med:

* SDF/TSDF
* CSG
* Komplekse organiske figurer
* Sammenkomponerede objekter
* Animationer der deformerer primitives
* Store scener med mange objekter

### 🔥 Derfor skal shaderen være:

* data-drevet
* scene-baseret
* generisk
* matematisk ren

### 🔥 Og ALLE objekter skal være:

* simple
* rene
* data-definerede
* uden shaderkode

Dette dokument formaliserer denne arkitektur.

---

# 10. Kort opsummering (TL;DR til Claude)

**Du må IKKE længere lave en shader pr. primitive.**
Claude skal:

* ✔️ Slette alle `*ShaderImpl` filer
* ✔️ Oprette `SdfSceneShader`
* ✔️ Flytte al SDF-kode til `AxRaymarchLib`
* ✔️ Flytte al materialekode til `AxMaterialLib`
* ✔️ Sikre at `AxDefaultShaders` kun returnerer `SdfSceneShader`
* ✔️ Opdatere alle AxObject-filer efter v0.2 + dette dokument
* ✔️ Bruge PdfObject til ALT geometry/materiale/transform

Resultat:

* Ingen shader-eksplosion
* Ingen lock-in
* Én matematisk elegant shader
* Objekter bliver ekstremt enkle
* Engine bliver ekstremt stærk

---

# 11. Afslutning

Denne refactor bringer AxiumForge over i en moderne, fleksibel og fuldt skalerbar SDF-arkitektur – nøjagtig den du har designet visionen for. Claude skal udføre refactoren nøjagtigt efter dette dokument og må ikke afvige fra modellen.

Dette dokument er **autoriteten** over shaderarkitekturen i AxiumForge v0.3.
