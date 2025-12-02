package;

import haxe.ds.ReadOnlyArray;
import obj.primitives.SphereShader;

typedef ShapeCategory = {
  name:String,
  shapes:Array<String>,
  package:String
};

/**
  Extracted shape registry + shader factory logic from Main.hx.
  Intended to be used by Main once refaktoreret.
**/
class ShapeCatalog {

  public static function defaultCategories():Array<ShapeCategory> {
    return [
      {name: "Primitives", shapes: ["Box", "Capsule", "Cone", "Cylinder", "Ellipsoid", "Plane", "Pyramid", "Sphere", "Torus"], package: "obj.primitives"},
      {name: "2D Primitives", shapes: ["Box2D", "Circle", "Heart", "RoundedBox2D", "Star"], package: "obj.primitives2d"},
      {name: "Derivates", shapes: ["HalfCapsule", "HoledPlane", "HollowBox", "HollowSphere", "QuarterTorus", "ShellCylinder"], package: "obj.derivates"},
      {name: "2D Organics", shapes: ["FlowerPetalRing", "LeafPair", "LeafSpiral", "LotusFringe", "OrnateKnot", "SpiralVine", "VineCurl"], package: "obj._2DOrganics"},
      {name: "3D Organic", shapes: ["BlobbyCluster", "BubbleCrown", "BulbTreeCrown", "DripCone", "JellyDonut", "KnotTube", "MeltedBox", "PuffyCross", "RibbonTwist", "SoftSphereWrap", "UndulatingPlane", "WavyCapsule"], package: "obj._3dOrganic"}
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
          var className = cat.package + "." + name + "Shader";
          var cls = Type.resolveClass(className);
          if (cls != null) {
            return cast Type.createInstance(cls, []);
          }
        }
      }
    }
    // Fallback to Sphere
    return new SphereShader();
  }
}
