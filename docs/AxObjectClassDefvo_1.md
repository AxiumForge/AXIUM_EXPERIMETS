# AxObjectClass Definition (v0.1)

Denne definition beskriver standardstrukturen for en AxiumForge "AxObjectClass" i Haxe. Alle AxObject-klasser **skal** have to faste metoder:

* `shader()` — returnerer en HXSL‑shader (RGBA, inkl. alpha)
* `object()` — returnerer et SDF/CSG‑drevet **PDF‑objekt** (Procedural Data Form)

Formålet er at etablere en ensartet og AI‑venlig klassestruktur, så alle komponenter i AxiumForge kan genereres, udvides og genbruges konsistent.

---

## 1. Navnekonvention

Hver AxObject‑klasse **skal** følge denne struktur:

```haxe
class Box implements AxObjectClass {
    public function new() {}

    public function shader():hxsl.Shader { ... }
    public function object():PdfObject { ... }
}
```

Faste navne:

* `shader()` **skal hedde dette** i alle objekter.
* `object()` **skal hedde dette** i alle objekter.

Begge metoder er **instansmetoder**, ikke statiske.

---

## 2. Interface: AxObjectClass

Alle AxObject‑klasser implementerer dette interface:

```haxe
interface AxObjectClass {
    public function shader():hxsl.Shader;
    public function object():PdfObject;
}
```

Dette sikrer:

* En ensartet API
* At AI‑genererede klasser automatisk matcher hub‑strukturen
* At renderer, fysik, serialisering og editorer kan arbejde generisk

---

## 3. Shader‑metoden

### Krav

* Returnerer en **HXSL shader**
* Farveformat: **RGBA** (float 0–1)
* Skal være kompatibel med AxiumForge SDF/TSDF‑pipelines
* Skal kunne modificeres af globale uniforms (belysning, tid, materialer)

### Minimal struktur

```haxe
public function shader():hxsl.Shader {
    return new hxsl.Shader(
        @:glsl("""
        // Vertex stage (kan være trivial i SDF 2D/3D)
        attribute vec3 position;
        void main() {
            gl_Position = vec4(position, 1.0);
        }

        // Fragment stage
        vec4 sdfColor = vec4(1.0, 1.0, 1.0, 1.0); // RGBA
        void fragment() {
            fragColor = sdfColor;
        }
        """)
    );
}
```

Shaderen kan senere **bruge** fælles biblioteker for bl.a.:

* Raymarching (AxRaymarchLib)
* Materiale‑system (AxMaterialLib)
* Alpha‑gradienter (AxAlphaLib)
* Procedural texturering (AxTexLib)

Disse er **ikke** metoder på AxObject‑klassen, men fælles matematiske moduler som shaderen kalder.

---

## 4. Object‑metoden

### Krav

* Returnerer et **PdfObject**
* PdfObject er AxiumForge's procedurale dataformat for SDF/TSDF/CSG baseret geometri
* Indeholder:

  * SDF byggeinstruktion
  * Materialer
  * Transform
  * Metadata

### Minimal PdfObject struktur (v0.1)

```haxe
typedef PdfObject = {
    name: String,
    sdf: {
        kind: String,        // "sphere", "box", "capsule", etc.
        params: Dynamic,     // radius, size, etc.
    },
    transform: {
        position: {x:Float, y:Float, z:Float},
        rotation: {x:Float, y:Float, z:Float},
        scale:    {x:Float, y:Float, z:Float},
    },
    material: {
        color: {r:Float, g:Float, b:Float, a:Float},
        roughness: Float,
        metallic: Float
    }
}
```

### Minimal implementation i en AxObject‑klasse

```haxe
public function object():PdfObject {
    return {
        name: "Box",
        sdf: {
            kind: "box",
            params: { size: [1.0, 1.0, 1.0] }
        },
        transform: {
            position: {x:0, y:0, z:0},
            rotation: {x:0, y:0, z:0},
            scale:    {x:1, y:1, z:1}
        },
        material: {
            color: {r:1, g:1, b:1, a:1},
            roughness: 0.5,
            metallic: 0.0
        }
    }
}
```

---

## 5. Eksempel på komplet AxObject‑klasse

```haxe
class Box implements AxObjectClass {
    public function new() {}

    // Returnerer RGBA HXSL shader
    public function shader():hxsl.Shader {
        return AxDefaultShaders.sdfBasicRgba();
    }

    // Returnerer PDF objekt data
    public function object():PdfObject {
        return {
            name: "Box",
            sdf: {
                kind: "box",
                params: { size: [1,1,1] }
            },
            transform: {
                position: {x:0, y:0, z:0},
                rotation: {x:0, y:0, z:0},
                scale:    {x:1, y:1, z:1}
            },
            material: {
                color: {r:1, g:1, b:1, a:1},
                roughness: 0.2,
                metallic: 0.0
            }
        }
    }
}
```

---

## 6. Formål med denne struktur

* Ensartet API til *alle* objekter i AxiumForge
* Let for AI‑agenter (GPT, Claude, Gemini) at generere nye aktiver
* Kompatibelt med både 2D‑SDF, 3D‑SDF og TSDF
* Matcher AxiumSystem (JDW/JDA/AXSL) pipelines
* Gør det muligt at:

  * serialisere assets
  * bygge editors
  * lave dynamisk load/reload
  * lave mesh‑conversion (marching cubes) senere

---

## 7. Ax‑libs: Raymarch, Material, Alpha, Texture

For at undgå at blande data, shader og algoritmer sammen defineres følgende fælles biblioteker uden for AxObject‑klasserne:

* `AxRaymarchLib`

  * Indeholder raymarching‑algoritmer (march‑loops, hit‑tests, max steps, epsilon osv.)
  * Arbejder på SDF/TSDF/CSG‑data fra `PdfObject`
  * Bruges af shaderen til at finde overflade‑hit per pixel

* `AxMaterialLib`

  * Evaluerer materiale ved et hit (farve, roughness, metallic, emission osv.)
  * Kan senere udvides til PBR, toon, stylized osv.

* `AxAlphaLib`

  * Helper‑funktioner til kanter, fades, cutouts, maske‑effekter
  * F.eks. edge‑fade, soft outlines, 2D‑layering

* `AxTexLib`

  * Procedurale mønstre og teksturer (noise, wood, marble, stripes, SDF‑baserede masks osv.)

AxObject‑klasserne eksponerer **kun**:

* `shader()` → vælger/bygger den shader, der bruger disse libs
* `object()` → leverer `PdfObject`‑data til raymarch/material/texture‑systemerne

Selve raymarching, materialer, alpha og teksturering er **fælles motorer**, ikke noget der gentages i hver enkelt AxObject‑klasse.

---

## 8. Version

* Dokumentversion: **v0.1**
* AxObjectClass version: **v0.1**
* Næste skridt: definér `PdfObject v0.2` og et fælles `AxShaderLib`

---
