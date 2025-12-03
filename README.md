
---

# **Axium Experiments**

### *A unified testbed for SDF, MSDF, TSDF, CSG and generative techniques in Heaps (Haxe)*

**Axium Experiments** er et levende laboratorium og opslagsværk, designet til at udforske hele spektret af moderne **matematiske og generative spilteknikker** i **Haxe + Heaps**.
Projektet fungerer både som:

1. **Et praktisk testmiljø** for hurtige eksperimenter i 2D, 2.5D og 3D.
2. **En reference-samling** af veldokumenterede eksempler, patterns og technical notes.
3. **Et “AI-venligt” repository**, som din AI-coder (Claude, GPT osv.) kan bruge til konsistent generering af korrekt kode, strukturer og shader-patterns.

Målet er at skabe **et sammenhængende vidensbibliotek** omkring procedurale teknikker i Heaps, med særlig fokus på SDF-baseret geometri, raymarching, materialer, MSDF glyph rendering, volumetriske data og hybrid pipelines mellem SDF, CSG og klassiske meshes.

---

## 🎯 **Formål**

Axium Experiments skal:

* Give **et samlet sted** hvor alle idéer kan prøves:
  SDF → MSDF → TSDF → CSG → Mesh → Hybrid.
* Dokumentere **best practices for Heaps + HXSL**, så alle eksperimenter kan gentages og forstås.
* Udvikle **et generativt mindset**: alt i spillet skal kunne beskrives matematisk eller data-drevet.
* Skabe et **unified Axium pipeline-bibliotek** der senere kan indgå i:

  * AxiumForge
  * AxiumSystem
  * Boblingverse
  * Render pipelines og asset-schemas (JDA / JDW / AxSL)
* Være en **playground** hvor hver ny teknik kan testes i isolation før den indgår i større projekter.

Du får ét sted at samle al viden, i stedet for at det ligger spredt ud over chats, sketches og eksperimenter.

---

## 🌌 **Hvad projektet dækker**

### 1. **SDF (Signed Distance Fields)**

* 2D og 3D primitiv-form konstruktion
* Kombination af former (union, subtract, intersect)
* Organiske former, hard-surface, blended edges
* Materialer, farvelag, alpha, multi-layered SDF
* Raymarching og per-pixel shading i HXSL
* 2D SDF som "motif carrier" på 3D overflader
* SDF-baserede effekter (bulge, morphing, noise)

### 2. **MSDF (Multi-channel Signed Distance Fields)**

* Tekst, UI-grafik, vector-til-MSDF workflows
* Billboards og 2D overlays
* Procedurale ikoner og symboler
* Kombineret med 3D SDF som hybrid UI-scene

### 3. **TSDF (Truncated Signed Distance Fields)**

* Volumetriske data
* Blød voxel modeling
* SDF-mesh extraction
* TSDF som “soft-voxel” stil i spil
* Destruktioner → frakturer → asteroide-splitting

### 4. **CSG (Constructive Solid Geometry)**

* Boolean operations
* Hybrid mesh + SDF workflows
* Hard surface modelering
* Generative strukturer (arkitektur, maskiner, rør, paneler)

### 5. **2D, 2.5D og pseudo-3D**

* Parallax 2D der tegnes med SDF
* 3D-objekter tegnet som “flade SDF-projektioner”
* Depth-sorted layers
* Fake-3D spilfølelse
* 2D assets genereret som matematisk data
* Integration med Box2D i spil-simulationer

### 6. **Generative og procedurale teknikker**

* Noise-familier (Perlin, Simplex, Worley, Domain Warp)
* Procedurale planeter, sten, asteroider, terræn
* Parametriske objekter (rumskibe, byer, maskiner)
* Random seeds og reproducérbare scener
* L-systems, grammar-based generation
* Data-driven instancing af objekter (AxSL + JDW)

---

## 🧱 **Arkitektur og filosofi**

Axium Experiments bygger på tre principper:

### **1. Alt er data**

Ingen assets skal være “hårdbagt”, hvis matematik kan generere dem.
SDF-data → shader
TSDF-data → volumetrisk buffer
MSDF → tekst / grafik
JDA → objekt
JDW → scene

### **2. Alt er modulært**

Hver test ligger som en lille mappe:

```
/experiments/
    sdf_basic/
    sdf_3d_raymarch/
    sdf_2d_on_3d/
    csg_union_tests/
    tsdf_chunks/
    msdf_glyphs/
    terrain_noise/
    asteroid_split/
```

Hver mappe indeholder:

* `Main.hx` – minimal Heaps setup
* `Shader.hx` – eksperimentets shader
* `Notes.md` – dokumentation
* Eventuelle hjælpekodefiler

### **3. Heaps som rendermotor, matematik som assets**

Projektet antager:

* Heaps = højtydende, fleksibel, shader-første pipeline
* Haxe = generativt, kompakt, cross-platform
* SDF/TSDF/CSG = fremtidens low-asset 2D/3D pipeline

---

## 🧪 **Hvad du kan forvente af projektet**

* En voksende samling af små, fokuserede eksempler
* Klare forklaringer i Notes.md til hvert eksempel
* Reusable kode til:

  * AxRaymarchLib
  * AxMaterialLib
  * AxTexLib
  * AxAlphaLib
  * AxDefaultShaders
* Eksempler du kan sende direkte til AI-coderen og bygge videre på

---

## 🚀 **Visionen**

Axium Experiments skal blive **det definitive opslagsværk** for:

* SDF i Heaps
* Matematisk generering af spilindhold
* Procedurale universer
* Hybrid 2D/3D teknik
* Asset-fri rendering

Et repository hvor enhver, inkl. dine AI-assistenter, kan slå op og forstå:

> "Hvordan gør man X med SDF/TSDF/MSDF/CSG i Heaps?"

---

## 📂 **Status**

**Version: v0.1**
De første eksperimenter etablerer:

* Minimal SDF pipeline i Heaps
* Baseline raymarcher
* 2D/3D unified rendering model
* Asset-fri procedurale scener

### Aktive moduler
- `HEAPS3D/3dobjectFarm` — 39 SDF-shapes med dynamisk shader swap, UI-panel og screenshot/sekvens-flow. Byg med `haxe build.hxml`, kør med `hl bin/main.hl`, brug `--sc`, `--seq`, eller `--<shape>` flags. Se `HEAPS3D/3dobjectFarm/README.md` for controls, issues og struktur.

---

## 🤝 Bidrag

Projektet er primært din egen R&D-arena, men struktureret så både mennesker og AI kan arbejde konsistent i det.

---
