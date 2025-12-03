# AxObjectClass Definition (v0.2)

Denne version v0.2 erstatter og præciserer v0.1. Den vigtigste ændring er en skarp adskillelse mellem:

* **AxObject-filer** (per-objekt klasser)
* **Engine-shaders** (fælles shader-klasser og libs i engine-laget)

Målet er:

* at holde hver objekt-fil **meget lille og ensartet**
* at undgå "shader-eksplosion" (én shader-klasse per objekt)
* at gøre det let for AI-værktøjer at generere og vedligeholde objekter

---

## 1. AxObject – grundidé

En AxObject er en ren, lille Haxe-klasse, der beskriver:

* **hvilken shader** objektet bruger (via en fælles shader-fabrik)
* **hvilket proceduralt objekt** (SDF/TSDF/CSG) der skal tegnes

Hver AxObject-klasse implementerer `AxObjectClass` interfacet og **skal** definere præcis to metoder:

```haxe
class Box implements AxObjectClass {
    public function new() {}

    public function shader():hxsl.Shader {
        // vælg shader her
    }

    public function object():PdfObject {
        // beskriv objekt-data her
    }
}
```

---

## 2. Filstruktur og "én klasse pr. fil"-reglen

For AxObject-filer gælder følgende:

1. Hver `*.hx` fil i AxObject-mappen indeholder **præcis én** Haxe-klasse

   * fx `Box.hx` indeholder kun `class Box implements AxObjectClass { ... }`
2. Klassen **skal** implementere interfacet `AxObjectClass`.
3. Klassen **skal** have følgende public metoder:

   * `public function shader():hxsl.Shader;`
   * `public function object():PdfObject;`
4. Klassen **må ikke** definere andre top-level klasser, fx ingen `class BoxShader` i samme fil.

Formål: Objekt-filer er fuldstændig forudsigelige og små – de er "data + valg af shader", ikke mini-engines.

---

## 3. Streng regel: Ingen shader-klasser i AxObject-filer

Dette var det manglende punkt i v0.1 og er nu gjort eksplicit:

> **AxObject-filer må ikke definere nye `hxsl.Shader` subklasser.**

Det betyder:

* INGEN af følgende i en AxObject-fil:

```haxe
class BoxShader extends hxsl.Shader {
    static var SRC = {
        // ...
    }
}
```

* INGEN oprettelse af nye shader-klasser, hverken lokalt eller som "hjælpeklasse" i samme fil.

AxObject-filer må kun **bruge** allerede eksisterende shader-klasser fra engine-laget – aldrig definere nye.

---

## 4. Hvor må shader-klasser så bo?

Shader-klasser hører til i **engine-laget**, ikke i AxObject-filerne.

Eksempel på engine-filer (kun eksempler, ikke en fuld liste):

* `AxRaymarchLib.hx` – HXSL-bibliotek til raymarch + SDF-funktioner
* `AxMaterialLib.hx` – HXSL-bibliotek til lys, materialer, normalberegning
* `AxRaymarchBaseShader.hx` – fælles raymarch RGBA-shader
* `AxDefaultShaders.hx` – Haxe helper/fabrik der returnerer passende shader-instancer

Disse filer må gerne definere `class Xxx extends hxsl.Shader` og bruge `static var SRC = { ... }` osv. De er en del af "motoren", ikke objekterne.

Kort sagt:

* ✅ Shader-klasser i engine-mappen er tilladt og forventet.
* ❌ Shader-klasser i AxObject-filer er ikke tilladt.

---

## 5. `shader()` – kontrakt og patterns

Signatur:

```haxe
public function shader():hxsl.Shader;
```

### 5.1 Hvad `shader()` må gøre

`shader()` må kun gøre følgende ting:

1. Hente en fælles shader-instans fra et engine-bibliotek

   * typisk via en helper/fabrik som `AxDefaultShaders`.
2. Sætte uniforms/parametre på den shader-instans (valgfrit).
3. Returnere shader-instansen.

Eksempel:

```haxe
public function shader():hxsl.Shader {
    var s = AxDefaultShaders.sdfBasicRgba();

    // Eksempel på objekt-specifik konfiguration (valgfrit):
    // s.setFloat("uRoughness", this.roughness);
    // s.setVec3("uBaseColor", this.color);

    return s;
}
```

### 5.2 Hvad `shader()` IKKE må gøre

I en AxObject-fil må `shader()` **ikke**:

* definere en ny shader-klasse:

  ```haxe
  class BoxShader extends hxsl.Shader { ... } // FORBUDT i AxObject-fil
  ```

* oprette unikke shader-typer pr. objekt (fx en `SphereShader`, `CapsuleShader` osv. inde i hver objekts fil)

* arbejde direkte med `hxsl.Parser`, `hxsl.Compiler` eller inline string-baseret shader-kode

Al shader-"hjerne" ligger i engine-laget.

---

## 6. `object()` – PdfObject kontrakt

Signatur:

```haxe
public function object():PdfObject;
```

`PdfObject` er en struktureret data-type, der beskriver:

* navnet på objektet
* SDF/TSDF/CSG-information
* transform (position, rotation, scale)
* materialedata (farve, roughness, metallic, osv.)

Et typisk eksempel kan se sådan ud (pseudo-type – tilpasses den endelige PdfObject-def):

```haxe
public function object():PdfObject {
    return {
        name: "Box",
        sdf: {
            kind: "box",
            params: {
                size: [1.0, 1.0, 1.0]
            }
        },
        transform: {
            position: { x: 0.0, y: 0.0, z: 0.0 },
            rotation: { x: 0.0, y: 0.0, z: 0.0 },
            scale:    { x: 1.0, y: 1.0, z: 1.0 }
        },
        material: {
            color:     { r: 1.0, g: 1.0, b: 1.0, a: 1.0 },
            roughness: 0.2,
            metallic:  0.0
        }
    };
}
```

Vigtigt:

* `object()` definerer kun **data** – ingen shader-kode, ingen raymarching, ingen HXSL.
* Alle felter skal følge den aftalte PdfObject-struktur, så motoren kan parse/generere scener.

---

## 7. Eksempel: Fuld `Box.hx` der overholder v0.2

```haxe
package axium.objects;

import hxsl.Shader;
import axium.AxObjectClass;
import axium.PdfObject;
import axium.AxDefaultShaders;

class Box implements AxObjectClass {
    public function new() {}

    // 1) Vælg en fælles shader
    public function shader():Shader {
        var s = AxDefaultShaders.sdfBasicRgba();
        // Her kan vi senere sætte uniforms baseret på Box'ens data, hvis nødvendigt.
        return s;
    }

    // 2) Beskriv det procedurale objekt
    public function object():PdfObject {
        return {
            name: "Box",
            sdf: {
                kind: "box",
                params: {
                    size: [1.0, 1.0, 1.0]
                }
            },
            transform: {
                position: { x: 0.0, y: 0.0, z: 0.0 },
                rotation: { x: 0.0, y: 0.0, z: 0.0 },
                scale:    { x: 1.0, y: 1.0, z: 1.0 }
            },
            material: {
                color:     { r: 1.0, g: 1.0, b: 1.0, a: 1.0 },
                roughness: 0.2,
                metallic:  0.0
            }
        };
    }
}
```

Denne fil:

* indeholder præcis én klasse (`Box`)
* implementerer `AxObjectClass`
* har `shader()` + `object()`
* bruger `AxDefaultShaders.sdfBasicRgba()` i stedet for at definere `BoxShader`
* beskriver al geometri/materiale via `PdfObject`

---

## 8. Opsummering af de vigtigste regler i v0.2

1. **Én klasse pr. AxObject-fil**

   * Filen indeholder kun `class Xxx implements AxObjectClass`.

2. **To faste metoder**

   * `shader():hxsl.Shader` – vælger/konfigurerer fælles engine-shader
   * `object():PdfObject` – beskriver objekt-data (SDF/TSDF/CSG + transform + materialer)

3. **Ingen shader-klasser i AxObject-filer**

   * Ingen `class BoxShader extends hxsl.Shader` i objektfiler.
   * AxObject-filer må kun bruge eksisterende engine-shaders (fx via `AxDefaultShaders`).

4. **Shader-klasser hører til i engine-laget**

   * Fx `AxRaymarchBaseShader`, `AxRaymarchToonShader`, libs i `AxRaymarchLib`, `AxMaterialLib`, osv.

5. **`object()` er ren data**

   * Ingen shader-kode, ingen raymarching, kun struktureret `PdfObject` data.

Med disse præciseringer fjerner v0.2 tvetydigheden fra v0.1:

* Claudes forslag om `BoxShader` i `Box.hx` er **ikke** kompatibelt med AxObjectClass v0.2.
* At have en fælles `AxRaymarchBaseShader` i engine-mappen er derimod **helt i tråd** med designet.
