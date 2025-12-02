package;

import h3d.pass.ScreenFx;
import h3d.Vector;
import hxd.App;
import hxd.Event;
import hxd.Window;
import hxd.Key;
import hxd.PixelFormat;
import hxd.Pixels;
import Sys;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;

class Main extends App {

  var fx  : ScreenFx<SDFLinkShader>;
  var sdf : SDFLinkShader;
  var t   : Float = 0.0;
  var yaw : Float = 0.0;
  var pitch : Float = 0.0;
  var roll : Float = 0.0;
  var distance : Float = 4.0;
  var pendingScreenshot = false;
  var autoScreenshot = false;
  var screenshotDir : String;

  static function main() {
    new Main();
  }

  override function init() {
    // vores SDF-raymarch shader
    sdf = new SDFLinkShader();
    fx  = new ScreenFx(sdf);
    Window.getInstance().addEventTarget(handleEvent);

    var progDir = Path.directory(Sys.programPath());
    var baseDir = Path.normalize(Path.join([progDir, "..", ".."])); // up from bin/ to HEAPS3D
    screenshotDir = Path.join([baseDir, "sc"]);
    for (arg in Sys.args()) {
      if (arg == "--sc") {
        pendingScreenshot = true;
        autoScreenshot = true;
      }
    }
  }

  override function update(dt:Float) {
    t += dt;
    // auto orbit on all 3 axes
    yaw += dt * 0.45;
    roll += dt * 0.3;
    pitch = Math.sin(t * 0.7) * 0.7;
  }

  override function render(e:h3d.Engine) {
    // opdater uniforms
    sdf.time = t;
    sdf.resolution.set(e.width, e.height);

    var camPos = computeCameraPos();
    var forward = computeRotated(new Vector(0, 0, -1));
    var right = computeRotated(new Vector(1, 0, 0));
    var up = computeRotated(new Vector(0, 1, 0));

    sdf.cameraPos.set(camPos.x, camPos.y, camPos.z);
    sdf.cameraForward.set(forward.x, forward.y, forward.z);
    sdf.cameraRight.set(right.x, right.y, right.z);
    sdf.cameraUp.set(up.x, up.y, up.z);

    // clear + kør fullscreen shader
    e.clear(0x000000);
    fx.render();

    if (pendingScreenshot) captureScreenshot(e);
  }

  function handleEvent(e:Event):Void {
    switch (e.kind) {
      case EWheel:
        // scroll/pinch zoom
        var zoomFactor = Math.pow(0.9, e.wheelDelta);
        distance = clamp(distance * zoomFactor, 1.0, 12.0);
      case EKeyDown:
        if (e.keyCode == Key.F12 || e.keyCode == Key.P) pendingScreenshot = true; // F12 primary, P fallback
      default:
    }
  }

  function computeCameraPos():Vector {
    return computeRotated(new Vector(0, 0, distance));
  }

  function computeRotated(v:Vector):Vector {
    var cy = Math.cos(yaw);
    var sy = Math.sin(yaw);
    var cp = Math.cos(pitch);
    var sp = Math.sin(pitch);
    var cr = Math.cos(roll);
    var sr = Math.sin(roll);

    // yaw (Y axis)
    var x1 = v.x * cy + v.z * sy;
    var y1 = v.y;
    var z1 = -v.x * sy + v.z * cy;

    // pitch (X axis)
    var x2 = x1;
    var y2 = y1 * cp - z1 * sp;
    var z2 = y1 * sp + z1 * cp;

    // roll (Z axis)
    var x3 = x2 * cr - y2 * sr;
    var y3 = x2 * sr + y2 * cr;
    var z3 = z2;

    return new Vector(x3, y3, z3);
  }

  static inline function clamp(v:Float, lo:Float, hi:Float):Float {
    return v < lo ? lo : (v > hi ? hi : v);
  }

  function captureScreenshot(engine:h3d.Engine) {
    pendingScreenshot = false;
    FileSystem.createDirectory(screenshotDir);
    var pix = Pixels.alloc(engine.width, engine.height, PixelFormat.RGBA);
    engine.driver.captureRenderBuffer(pix);
    pix.convert(PixelFormat.RGBA);
    var stamp = Std.int(t * 1000);
    var fileName = "shot_" + stamp + ".png";
    var fullPath = Path.join([screenshotDir, fileName]);
    File.saveBytes(fullPath, pix.toPNG());
    if (autoScreenshot) Sys.exit(0);
  }
}
