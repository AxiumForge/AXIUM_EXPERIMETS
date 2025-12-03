package;

/**
  AxObjectClass v0.1 Standard Interface

  Defines the contract for all SDF shape objects in the 3dobjectFarm system.
  Each shape must provide:
  - shader(): Returns the HXSL shader for GPU raymarching
  - object(): Returns PdfObject metadata for the shape

  This replaces the old pattern of static methods and separate shader classes.
**/
interface AxObjectClass {
  public function shader():hxsl.Shader;
  public function object():PdfObject;
}
