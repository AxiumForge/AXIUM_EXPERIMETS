# SDF formbibliotek

Denne mappe samler små, isolerede Haxe-klasser med signed distance-funktioner og farveinfo, så du hurtigt kan komponere/scanne SDF-scener uden at pakke alt i én shaderfil.

## Struktur
- `primitives/` – basale 3D former (kasse, sfære, torus, kapsel, cylinder, kegle, plan, ellipsoid osv.).
- `derivates/` – variationer/boolean-udgaver (udhulninger, shells, kvart-torus, hul plane, halv kapsel m.m.).
- `3dOrganic/` – organiske 3D former: blobby clusters, wavy capsules, knot tubes, undulerende plane, puffy cross, m.v. Flere er tidsafhængige (kræver `time` i distance-kald).
- `2dprimitives/` – enkle 2D-SDF’er (circle/box/rounded/heart/star på x/z-plan).
- `2DOrganics/` – ornamenter og organiske 2D-mønstre (spiral vine, leaves, petals, lotus fringe, knude, m.v.).

## Brug
- Hver fil har en `distance(p:Vector)` (nogle har også `time`) og en `color`-vektor. Parametre som center/radius/tykkelse er exposed som `inline` felter.
- Til animation: former der bruger `time` (fx `SoftSphereWrap`, `WavyCapsule`, `UndulatingPlane`) skal kaldes med en tidsværdi for wobble/bølge.
- Typisk workflow: oversæt `p` ind i lokalspace (p - center), kald `distance`, brug farven til shading eller blending. Combine via min/union/smooth union efter behov.

## Eksempler
- 3D base: `obj.primitives.Sphere.distance(p - Sphere.center);`
- Variant: `obj.derivates.HollowBox.distance(p - HollowBox.center);`
- Organisk anim: `obj._3dOrganic.SoftSphereWrap.distance(p - SoftSphereWrap.center, time);`
- Ornament 2D: `obj._2DOrganics.FlowerPetalRing.distance(pLocal);`

Målet er hurtig genbrug og eksperimentering: træk former ind i shader-koden, kombiner dem, og iterér på parametrerne uden at tabe overblik.***
