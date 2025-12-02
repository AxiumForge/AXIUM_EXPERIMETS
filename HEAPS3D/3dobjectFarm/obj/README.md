# SDF formbibliotek

Denne mappe samler små, isolerede Haxe-moduler med signed distance-funktioner, GPU-shaders og farveinfo, så du hurtigt kan komponere/scanne SDF-scener.

## Module Pattern

Hver `.hx` fil er et **Haxe modul** med to klasser:

1. **Primær type** - Form data og CPU distance function
2. **Shader sub-type** - GPU shader implementation (HXSL)

Dette følger Haxe best practices for module organisation.

### Eksempel: Sphere.hx

```haxe
package obj.primitives;

import h3d.Vector;

// Primær type - data og CPU funktion
class Sphere {
    public static var color = new Vector(0.2, 0.7, 1.0);
    public static var radius = 0.6;

    public static inline function distance(p:Vector):Float {
        return p.length() - radius;
    }
}

// Shader sub-type - GPU implementation
class SphereShader extends BaseRaymarchShader {
    static var SRC = {
        @param var time : Float;

        function map(p:Vec3):Vec4 {
            var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
            var dist = length(pr) - 0.6;
            var col = vec3(0.2, 0.7, 1.0);
            return vec4(dist, col.x, col.y, col.z);
        }
    }
}
```

## Struktur

- **primitives/** – basale 3D former (Box, Sphere, Torus, Capsule, Cylinder, Cone, Plane, Ellipsoid, Pyramid)
- **primitives2d/** – 2D-SDF'er extruded til 3D (Circle, Box2D, Heart, RoundedBox2D, Star)
- **derivates/** – variationer (HollowBox, HollowSphere, ShellCylinder, QuarterTorus, HoledPlane, HalfCapsule)
- **2DOrganics/** – organiske 2D-mønstre (FlowerPetalRing, LeafSpiral, SpiralVine, VineCurl, LotusFringe, OrnateKnot, LeafPair)
- **3dOrganic/** – organiske 3D former (BlobbyCluster, WavyCapsule, KnotTube, UndulatingPlane, PuffyCross, RibbonTwist, SoftSphereWrap, BubbleCrown, BulbTreeCrown, DripCone, JellyDonut, MeltedBox)

## Brug

### CPU-side (data og testing)
```haxe
import obj.primitives.Sphere;

// Tilgå data
var color = Sphere.color;
var radius = Sphere.radius;

// Brug CPU distance function
var dist = Sphere.distance(point);
```

### GPU-side (rendering)
```haxe
import obj.primitives.Sphere;

// Instantier shader
var shader = new SphereShader();
shader.time = currentTime;

// Brug i render pipeline
fx.addShader(shader);
```

## HXSL Syntax

Ved konvertering fra Haxe til HXSL:

| Haxe | HXSL |
|------|------|
| `Math.sqrt()` | `sqrt()` |
| `Math.abs()` | `abs()` |
| `Math.atan2(y, x)` | `atan(y / x)` |
| `Math.PI` | `3.14159265` |
| `%` (modulo) | `mod()` |
| `new Vector(x, y, z)` | `vec3(x, y, z)` |
| Linear interp | `mix(a, b, t)` |

## Tilføj ny form

1. Opret fil: `obj/[category]/NewShape.hx`

2. Definer data klasse:
```haxe
class NewShape {
    public static var color = new Vector(r, g, b);
    public static var size = value;

    public static inline function distance(p:Vector):Float {
        // SDF beregning
    }
}
```

3. Definer shader klasse:
```haxe
class NewShapeShader extends BaseRaymarchShader {
    static var SRC = {
        @param var time : Float;

        function map(p:Vec3):Vec4 {
            var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
            var dist = /* HXSL beregning */;
            var col = vec3(r, g, b);
            return vec4(dist, col.x, col.y, col.z);
        }
    }
}
```

4. Registrer i `Main.hx` `shapeCategories` array

## Arkitektur

Dette pattern følger:
- **Haxe conventions** - én primær type + sub-types i samme modul
- **HXSL philosophy** - små focused shaders (ikke Uber Shader)
- **Separation of concerns** - CPU data/logic adskilt fra GPU shader
- **Vedligeholdelse** - alt for én form i én fil

Se `docs/haxe-heaps-patterns.md` for detaljeret research og references.

## Resources

- [Inigo Quilez - 3D SDF Functions](https://iquilezles.org/articles/distfunctions/)
- [Inigo Quilez - 2D SDF Functions](https://iquilezles.org/articles/distfunctions2d/)
- [Heaps HXSL Documentation](https://heaps.io/documentation/hxsl.html)

Målet er hurtig genbrug og eksperimentering: træk former ind, kombiner dem, og iterér på parametrerne uden at tabe overblik.
