# CHANGELOG

## 2025-12-03 - AxObjectClass Self-Contained Pattern (v0.4)

### Major Architectural Shift
- **NEW PATTERN:** Self-contained plug & play shapes - each shape file contains BOTH AxObjectClass implementation AND its dedicated shader class
- **REMOVED DEPENDENCY:** Shapes no longer depend on AxDefaultShaders, AxRaymarchLib, or SdfSceneShader
- **BaseRaymarchShader:** Now contains ONLY world-level concerns (raymarching, lighting, camera) - NO shape-specific code

### Completed (9/39 shapes)
**Primitives converted to self-contained pattern:**
- ✅ Box.hx - Contains Box + BoxShader classes with sdfBox SDF math
- ✅ Sphere.hx - Contains Sphere + SphereShader classes with sdfSphere SDF math
- ✅ Capsule.hx - Contains Capsule + CapsuleShader classes with sdfCapsule SDF math
- ✅ Cone.hx - Contains Cone + ConeShader classes with sdfCone SDF math
- ✅ Cylinder.hx - Contains Cylinder + CylinderShader classes with sdfCylinder SDF math
- ✅ Ellipsoid.hx - Contains Ellipsoid + EllipsoidShader classes with sdfEllipsoid SDF math
- ✅ Plane.hx - Contains Plane + PlaneShader classes with sdfPlane SDF math
- ✅ Pyramid.hx - Contains Pyramid + PyramidShader classes with sdfPyramid SDF math
- ✅ Torus.hx - Contains Torus + TorusShader classes with sdfTorus SDF math

**Each shape file structure:**
```haxe
class Shape implements AxObjectClass {
  public function shader():hxsl.Shader { return new ShapeShader(); }
  public function object():PdfObject { return {...}; }
}

class ShapeShader extends BaseRaymarchShader {
  static var SRC = {
    @param var shapeSize : Vec3;
    @param var shapeColor : Vec3;

    function rotateXYZ(p:Vec3, r:Vec3):Vec3 { ... }
    function sdfShape(p:Vec3, ...):Float { ... }
    function map(p:Vec3):Vec4 { ... }
  };
}
```

### Remaining Work (30/39 shapes)
**TODO - Convert to AxObjectClass interface:**
- 2D Primitives (5): Box2D, Circle, Heart, RoundedBox2D, Star
- Derivates (6): HalfCapsule, HoledPlane, HollowBox, HollowSphere, QuarterTorus, ShellCylinder
- 2D Organics (7): FlowerPetalRing, LeafPair, LeafSpiral, LotusFringe, OrnateKnot, SpiralVine, VineCurl
- 3D Organics (12): BlobbyCluster, BubbleCrown, BulbTreeCrown, DripCone, JellyDonut, KnotTube, MeltedBox, PuffyCross, RibbonTwist, SoftSphereWrap, UndulatingPlane, WavyCapsule

**Note:** These 30 shapes already have XxxShader classes but lack AxObjectClass wrapper implementation.

### Alpha/Transparency Fix
- ✅ Fixed alpha support for ALL shapes via BaseRaymarchShader.fragment() using `mix(background, shaded, alphaControl)`
- All primitives now support alpha transparency control via LEFT/RIGHT arrow keys

### Files Pending Deletion (After all 39 shapes converted)
When all conversions complete, these files can be deleted (~360 lines):
- AxDefaultShaders.hx - Factory methods + 9 *ShaderImpl classes (now in shape files)
- AxRaymarchLib.hx - SDF functions (copied into each shape file)
- SdfSceneShader.hx - Universal v0.3 shader (replaced by individual ShapeShader classes)
- AxMaterialLib.hx - Redundant (functions already in BaseRaymarchShader)

### Build Status
- ✅ All 9 converted primitives build successfully
- ✅ Tested: Box, Sphere, Cylinder, Torus - all render correctly with alpha support
- ⚠️ Remaining 30 shapes fail at runtime: "obj.primitives2d.Circle has no method shader"

### Next Session
Continue converting remaining 30 shapes to AxObjectClass format, then delete obsolete library files.

---

## Previous Versions

### AxObjectClass v0.3 (Attempted - Abandoned)
- Attempted universal SdfSceneShader with shapeType parameter
- Abandoned due to distributed complexity and lock-in architecture

### AxObjectClass v0.2
- Individual *ShaderImpl classes in AxDefaultShaders.hx
- Box, Capsule, Cone, Cylinder, Ellipsoid, Plane, Pyramid, Sphere, Torus
- Factory pattern with AxDefaultShaders central hub

### AxObjectClass v0.1
- Initial implementation with Box as pilot
- Established AxObjectClass interface and PdfObject typedef
