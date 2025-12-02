# Haxe & Heaps Patterns - RAG Document

*Research findings for module organization and shader patterns*

## Haxe Module Organization

### Multiple Classes in Same File
Each .hx file represents a **module** which may contain several types.

**Key Sources:**
- [Modules and Paths - Haxe Manual](https://haxe.org/manual/type-system-modules-and-paths.html)
- [Module Sub-Types - Haxe Manual](https://haxe.org/manual/type-system-module-sub-types.html)
- [Import - Haxe Manual](https://haxe.org/manual/type-system-import.html)

### Best Practices
1. **One primary class per file** - filename should match the class name
2. **Module sub-types** - additional types can exist in same file
   - Type name must be unique in whole application
   - Sub-types accessed via `package.Module.SubType`
   - Can be marked `private` for module-only access
3. **Module names** must start with uppercase

**Example:**
```haxe
// Box.hx
class Box {  // Primary type
    public static var data = ...;
}

class BoxHelper {  // Sub-type
    // helper code
}

private class BoxInternal {  // Private sub-type
    // only accessible from Box.hx
}
```

## Haxe Type System

### Typedef
**Purpose:** Give a name/alias to complex types. NOT just textual replacement - actual real types.

**Source:** [Typedef - Haxe Manual](https://haxe.org/manual/type-system-typedef.html)

**Example:**
```haxe
typedef ShapeData = {
    color: Vector,
    dimensions: Vector
}
```

### Abstract Types
**Purpose:** Type-safe wrappers with zero runtime overhead. More powerful than typedef.

**Sources:**
- [Abstract - Haxe Manual](https://haxe.org/manual/types-abstract.html)
- [Abstracting Primitives - Haxe Blog](https://haxe.org/blog/abstracting-primitives/)
- [Forwarding abstract fields](https://haxe.org/manual/types-abstract-forward.html)

**Key Features:**
- Provides type safety (unlike typedef which preserves original semantics)
- Can define implicit casts
- Can overload operators
- Zero runtime cost

## HXSL & Heaps Shader Organization

### HXSL Philosophy
**"Multiple small shader effects > One Uber Shader"**

HXSL links shaders together at runtime, allowing you to:
- Split shader into distinct effects
- Enable/disable effects easily
- Optimize out unused code automatically

**Key Sources:**
- [HXSL Documentation - Heaps.io](https://heaps.io/documentation/hxsl.html)
- [HXSL Wiki - GitHub](https://github.com/HeapsIO/heaps/wiki/HXSL)
- [Shaders - Heaps.io](https://heaps.io/documentation/shaders.html)
- [hxsl.Shader API](https://heaps.io/api/hxsl/Shader.html)
- [h3d.shader.ScreenShader API](https://heaps.io/api/h3d/shader/ScreenShader.html)

### Shader Structure
```haxe
class MyShader extends hxsl.Shader {
    static var SRC = {
        @input var input : Vec3;     // Vertex inputs
        @param var color : Vec3;      // Parameters (uniforms)
        @var var uv : Vec2;           // Varying (vertex->fragment)
        @const var mode : Int;        // Compile-time constant
        var output : Vec4;            // Output

        function vertex() {
            // vertex shader
        }

        function fragment() {
            // fragment shader
        }
    }
}
```

### Runtime Linking & Optimization
HXSL automatically:
1. **Links** shaders together (ensures variables are written before read)
2. **Optimizes** unused code (branches with @const)
3. **Compiles** to platform-specific languages (GLSL, HLSL, PSSL, AGAL)

## Recommended Pattern for SDF Shapes

### Pattern: Module with Primary Type + Shader Sub-Type

**File:** `obj/primitives/Box.hx`

```haxe
package obj.primitives;

import h3d.Vector;

// Primary type - data and CPU-side code
class Box {
    public static var color = new Vector(0.65, 0.35, 0.55);
    public static var halfExtents = new Vector(0.5, 0.35, 0.45);

    public static inline function distance(p:Vector):Float {
        // CPU distance function
        var q = abs(p) - halfExtents;
        return length(max(q, vec3(0))) + min(max(q.x, max(q.y, q.z)), 0.0);
    }
}

// Sub-type - GPU shader
class BoxShader extends BaseRaymarchShader {
    static var SRC = {
        @param var time : Float;

        function map(p:Vec3):Vec4 {
            var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
            var b = vec3(0.5, 0.35, 0.45);
            var q = abs(pr) - b;
            var dist = length(max(q, vec3(0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);
            var col = vec3(0.65, 0.35, 0.55);
            return vec4(dist, col.x, col.y, col.z);
        }
    }
}
```

### Why This Pattern Works

1. **Follows Haxe conventions:**
   - One primary type per file (Box)
   - Sub-type for related functionality (BoxShader)
   - Both types in same module for easy maintenance

2. **Follows HXSL best practices:**
   - Small, focused shader (not Uber Shader)
   - Can be linked with other shaders at runtime
   - Automatic optimization

3. **Maintainability:**
   - Everything for one shape in one file
   - CPU code and GPU code side-by-side
   - Easy to add/modify shapes

4. **Type safety:**
   - BoxShader is distinct type (not same as SphereShader)
   - Can be referenced explicitly: `obj.primitives.Box.BoxShader`

## Alternative: Typedef Pattern

```haxe
package obj.primitives;

// Data structure
typedef BoxData = {
    color: Vector,
    halfExtents: Vector
}

// Shader with embedded data
class BoxShader extends BaseRaymarchShader {
    public static var data:BoxData = {
        color: new Vector(0.65, 0.35, 0.55),
        halfExtents: new Vector(0.5, 0.35, 0.45)
    };

    static var SRC = {
        @param var time : Float;

        function map(p:Vec3):Vec4 {
            // shader code using data values
        }
    }
}
```

**When to use:**
- When you want stronger typing for data structure
- When data is primarily used by shader
- When you don't need CPU distance function

## References

### Haxe Language
- [Haxe Manual - Type System](https://haxe.org/manual/type-system.html)
- [Haxe Manual - Modules](https://haxe.org/manual/type-system-modules-and-paths.html)
- [Haxe Manual - Module Sub-Types](https://haxe.org/manual/type-system-module-sub-types.html)
- [Haxe Manual - Typedef](https://haxe.org/manual/type-system-typedef.html)
- [Haxe Manual - Abstract](https://haxe.org/manual/types-abstract.html)
- [Learn Haxe in Y Minutes](https://learnxinyminutes.com/haxe/)

### HXSL & Heaps
- [Heaps.io Documentation Home](https://heaps.io/documentation/home.html)
- [HXSL Documentation](https://heaps.io/documentation/hxsl.html)
- [HXSL Wiki](https://github.com/HeapsIO/heaps/wiki/HXSL)
- [Shaders Documentation](https://heaps.io/documentation/shaders.html)
- [hxsl.Shader API](https://heaps.io/api/hxsl/Shader.html)
- [hxsl.SharedShader API](https://heaps.io/api/hxsl/SharedShader.html)
- [h3d.shader.ScreenShader API](https://heaps.io/api/h3d/shader/ScreenShader.html)
- [Shiro Games Stack](https://heaps.io/documentation/fullstack.html)

### Stack Overflow
- [How to use modules in modules](https://stackoverflow.com/questions/40502706/how-to-use-modules-in-modules)
- [Haxe: Using abstracts to define groups of types](https://stackoverflow.com/questions/51690512/haxe-using-abstracts-to-define-groups-of-types)
- [How to import packages in nested directories](https://stackoverflow.com/questions/40961673/how-to-import-packages-in-nested-directories-haxe)

---

*Document created: 2025-12-02*
*Purpose: Avoid redundant web searches for Haxe/Heaps patterns*
