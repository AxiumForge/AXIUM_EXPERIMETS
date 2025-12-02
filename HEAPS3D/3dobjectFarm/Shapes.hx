package;

// Barrel file for all SDF shape imports
// Import this file instead of importing each shape individually

// Primitives
import obj.primitives.Box;
import obj.primitives.Sphere;
import obj.primitives.Capsule;
import obj.primitives.Cone;
import obj.primitives.Cylinder;
import obj.primitives.Ellipsoid;
import obj.primitives.Plane;
import obj.primitives.Pyramid;
import obj.primitives.Torus;

// 2D Primitives
import obj.primitives2d.Box2D;
import obj.primitives2d.Circle;
import obj.primitives2d.Heart;
import obj.primitives2d.RoundedBox2D;
import obj.primitives2d.Star;

// Derivates
import obj.derivates.HalfCapsule;
import obj.derivates.HoledPlane;
import obj.derivates.HollowBox;
import obj.derivates.HollowSphere;
import obj.derivates.QuarterTorus;
import obj.derivates.ShellCylinder;

// 2D Organics
import obj.organics2d.FlowerPetalRing;
import obj.organics2d.LeafPair;
import obj.organics2d.LeafSpiral;
import obj.organics2d.LotusFringe;
import obj.organics2d.OrnateKnot;
import obj.organics2d.SpiralVine;
import obj.organics2d.VineCurl;

// 3D Organics
import obj.organics3d.BlobbyCluster;
import obj.organics3d.BubbleCrown;
import obj.organics3d.BulbTreeCrown;
import obj.organics3d.DripCone;
import obj.organics3d.JellyDonut;
import obj.organics3d.KnotTube;
import obj.organics3d.MeltedBox;
import obj.organics3d.PuffyCross;
import obj.organics3d.RibbonTwist;
import obj.organics3d.SoftSphereWrap;
import obj.organics3d.UndulatingPlane;
import obj.organics3d.WavyCapsule;

/**
  Barrel file that imports all 39 SDF shape classes.
  Makes them available to Type.resolveClass() when this file is imported.

  Usage:
  ```haxe
  import Shapes; // Imports all shape classes
  ```
**/
class Shapes {
  // Empty class - just serves as anchor for the imports
}
