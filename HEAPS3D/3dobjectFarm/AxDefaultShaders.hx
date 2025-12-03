package;

/**
  AxDefaultShaders - Shader factory library for AxObjectClass v0.3

  Provides ONE universal scene-based shader for ALL primitives.
  Data-driven rendering - geometry defined in PdfObject, not in shaders.
**/
class AxDefaultShaders {

  public static function sdfSceneShader():SdfSceneShader {
    return new SdfSceneShader();
  }

  // ========== v0.2 LEGACY (deprecated, will be removed) ==========

  public static function boxShader():BoxShaderImpl {
    return new BoxShaderImpl();
  }

  public static function capsuleShader():CapsuleShaderImpl {
    return new CapsuleShaderImpl();
  }

  public static function coneShader():ConeShaderImpl {
    return new ConeShaderImpl();
  }

  public static function cylinderShader():CylinderShaderImpl {
    return new CylinderShaderImpl();
  }

  public static function ellipsoidShader():EllipsoidShaderImpl {
    return new EllipsoidShaderImpl();
  }

  public static function planeShader():PlaneShaderImpl {
    return new PlaneShaderImpl();
  }

  public static function pyramidShader():PyramidShaderImpl {
    return new PyramidShaderImpl();
  }

  public static function sphereShader():SphereShaderImpl {
    return new SphereShaderImpl();
  }

  public static function torusShader():TorusShaderImpl {
    return new TorusShaderImpl();
  }
}

/**
  BoxShaderImpl - Configurable box SDF shader with uniforms

  Uniforms that Box.shader() should set:
  - boxSize (Vec3): half extents of the box
  - boxColor (Vec3): RGB color of the box
**/
class BoxShaderImpl extends BaseRaymarchShader {
  static var SRC = {
    @param var boxSize : Vec3;
    @param var boxColor : Vec3;

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var q = abs(pr) - boxSize;
      var dist = length(max(q, vec3(0.0, 0.0, 0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);
      return vec4(dist, boxColor.x, boxColor.y, boxColor.z);
    }
  };
}

/**
  CapsuleShaderImpl - Configurable capsule SDF shader

  Uniforms:
  - capsuleA (Vec3): start point
  - capsuleB (Vec3): end point
  - capsuleRadius (Float): radius
  - capsuleColor (Vec3): RGB color
**/
class CapsuleShaderImpl extends BaseRaymarchShader {
  static var SRC = {
    @param var capsuleA : Vec3;
    @param var capsuleB : Vec3;
    @param var capsuleRadius : Float;
    @param var capsuleColor : Vec3;

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var pa = pr - capsuleA;
      var ba = capsuleB - capsuleA;
      var h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
      var dist = length(pa - ba * h) - capsuleRadius;
      return vec4(dist, capsuleColor.x, capsuleColor.y, capsuleColor.z);
    }
  };
}

class ConeShaderImpl extends BaseRaymarchShader {
  static var SRC = {
    @param var coneHeight : Float;
    @param var coneRadius : Float;
    @param var coneColor : Vec3;

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var h = coneHeight;
      var r = coneRadius;
      var q = length(vec2(pr.x, pr.z));
      var dist = max(dot(vec2(r, h), vec2(q, pr.y)) / (r * r + h * h), -pr.y - h) * sqrt(r * r + h * h) / r;
      return vec4(dist, coneColor.x, coneColor.y, coneColor.z);
    }
  };
}

class CylinderShaderImpl extends BaseRaymarchShader {
  static var SRC = {
    @param var cylinderRadius : Float;
    @param var cylinderHalfHeight : Float;
    @param var cylinderColor : Vec3;

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var d = vec2(length(vec2(pr.x, pr.z)) - cylinderRadius, abs(pr.y) - cylinderHalfHeight);
      var dist = min(max(d.x, d.y), 0.0) + length(max(d, vec2(0.0, 0.0)));
      return vec4(dist, cylinderColor.x, cylinderColor.y, cylinderColor.z);
    }
  };
}

class EllipsoidShaderImpl extends BaseRaymarchShader {
  static var SRC = {
    @param var ellipsoidRadii : Vec3;
    @param var ellipsoidColor : Vec3;

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var r = ellipsoidRadii;
      var k0 = length(pr / r);
      var k1 = length(pr / (r * r));
      var dist = k0 * (k0 - 1.0) / k1;
      return vec4(dist, ellipsoidColor.x, ellipsoidColor.y, ellipsoidColor.z);
    }
  };
}

class PlaneShaderImpl extends BaseRaymarchShader {
  static var SRC = {
    @param var planeOffset : Float;
    @param var planeColor : Vec3;

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = pr.y + planeOffset;
      return vec4(dist, planeColor.x, planeColor.y, planeColor.z);
    }
  };
}

class SphereShaderImpl extends BaseRaymarchShader {
  static var SRC = {
    @param var sphereRadius : Float;
    @param var sphereColor : Vec3;

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var dist = length(pr) - sphereRadius;
      return vec4(dist, sphereColor.x, sphereColor.y, sphereColor.z);
    }
  };
}

class TorusShaderImpl extends BaseRaymarchShader {
  static var SRC = {
    @param var torusMajorRadius : Float;
    @param var torusMinorRadius : Float;
    @param var torusColor : Vec3;

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var q = vec2(length(vec2(pr.x, pr.z)) - torusMajorRadius, pr.y);
      var dist = length(q) - torusMinorRadius;
      return vec4(dist, torusColor.x, torusColor.y, torusColor.z);
    }
  };
}

class PyramidShaderImpl extends BaseRaymarchShader {
  static var SRC = {
    @param var pyramidHeight : Float;
    @param var pyramidColor : Vec3;

    function map(p:Vec3):Vec4 {
      var pr = rotateXYZ(p, vec3(time * 0.5, time * 0.7, time * 0.3));
      var h = pyramidHeight;
      var m2 = h * h + 0.25;
      var pxz = abs(vec2(pr.x, pr.z));
      if (pxz.y > pxz.x) {
        pxz = pxz.yx;
        pr = vec3(pr.z, pr.y, pr.x);
      }
      pxz -= 0.5;
      var py = pr.y - h;
      var q = vec3(pxz.x, py * h + pxz.y * 0.5, pxz.y);
      var s = max(-q.y, 0.0);
      var a = m2 * q.x * q.x - h * h * q.y * q.y;
      var k = clamp((q.x * h + q.y * 0.5) / m2, 0.0, 1.0);
      var b = m2 * (q.x - k * h) * (q.x - k * h) + q.y * q.y - 0.25 * k * k;
      var d = a > 0.0 ? sqrt(a) / m2 : -q.y;
      var d2 = b > 0.0 ? sqrt(b) / m2 : (-q.y - k * 0.5);
      var dist = length(vec2(max(d, s), max(d2, s)));
      dist = (max(q.y, -py) < 0.0) ? -dist : dist;
      return vec4(dist, pyramidColor.x, pyramidColor.y, pyramidColor.z);
    }
  };
}
