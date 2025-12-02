package;

import haxe.ds.ReadOnlyArray;

typedef ShapeCategory = {
  name:String,
  shapes:Array<String>,
  pkg:String
};

/**
  Extracted shape registry + shader factory logic from Main.hx.
  Intended to be used by Main once refaktoreret.
**/
class ShapeCatalog {

  public static function defaultCategories():Array<ShapeCategory> {
    return [
      {name: "Primitives", shapes: ["Box", "Capsule", "Cone", "Cylinder", "Ellipsoid", "Plane", "Pyramid", "Sphere", "Torus"], pkg: "obj.primitives"},
      {name: "2D Primitives", shapes: ["Box2D", "Circle", "Heart", "RoundedBox2D", "Star"], pkg: "obj.primitives2d"},
      {name: "Derivates", shapes: ["HalfCapsule", "HoledPlane", "HollowBox", "HollowSphere", "QuarterTorus", "ShellCylinder"], pkg: "obj.derivates"},
      {name: "2D Organics", shapes: ["FlowerPetalRing", "LeafPair", "LeafSpiral", "LotusFringe", "OrnateKnot", "SpiralVine", "VineCurl"], pkg: "obj.organics2d"},
      {name: "3D Organic", shapes: ["BlobbyCluster", "BubbleCrown", "BulbTreeCrown", "DripCone", "JellyDonut", "KnotTube", "MeltedBox", "PuffyCross", "RibbonTwist", "SoftSphereWrap", "UndulatingPlane", "WavyCapsule"], pkg: "obj.organics3d"}
    ];
  }

  public static function shapeNames(categories:ReadOnlyArray<ShapeCategory>):Array<String> {
    var names:Array<String> = [];
    for (cat in categories) {
      for (shape in cat.shapes) {
        names.push(shape);
      }
    }
    return names;
  }

  /** Create shader instance for a given shape name using categories. */
  public static function createShaderForShape(name:String, categories:ReadOnlyArray<ShapeCategory>):BaseRaymarchShader {
    for (cat in categories) {
      for (shapeName in cat.shapes) {
        if (shapeName == name) {
          var className = cat.pkg + "." + name + "Shader";
          var cls = Type.resolveClass(className);
          if (cls != null) {
            return cast Type.createInstance(cls, []);
          }
        }
      }
    }
    // Fallback to Sphere shader
    var sphereCls = Type.resolveClass("obj.primitives.SphereShader");
    if (sphereCls != null) {
      return cast Type.createInstance(sphereCls, []);
    }
    throw "Failed to create fallback shader";
  }
}
