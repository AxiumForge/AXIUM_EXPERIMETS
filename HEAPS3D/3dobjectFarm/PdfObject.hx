package;

/**
  PdfObject - Metadata structure for SDF shapes

  Provides a JSON-serializable description of a shape for export,
  documentation, or procedural scene generation.

  Fields:
  - name: Human-readable shape identifier
  - sdf: SDF function metadata (kind = function name, params = shape parameters)
  - transform: Spatial transformation (position, rotation, scale)
  - material: Visual properties (color, roughness, metallic, etc.)
**/
typedef PdfObject = {
  name: String,
  sdf: {
    kind: String,
    params: Dynamic
  },
  transform: {
    position: {x:Float, y:Float, z:Float},
    rotation: {x:Float, y:Float, z:Float},
    scale: {x:Float, y:Float, z:Float}
  },
  material: {
    color: {r:Float, g:Float, b:Float, a:Float},
    roughness: Float,
    metallic: Float
  }
}
