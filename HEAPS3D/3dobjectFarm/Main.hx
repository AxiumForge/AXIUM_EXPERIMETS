package;

import h3d.pass.ScreenFx;
import h3d.pass.Copy;
import h3d.Vector;
import h3d.mat.Texture;
import h2d.Text;
import h2d.Interactive;
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

  var fx : ScreenFx<SDFObjectFarmShader>;
  var shader : SDFObjectFarmShader;
  var renderTarget : Texture;
  var copy : Copy;
  var t : Float = 0.0;
  var distance : Float = 5.0;
  var pendingScreenshot = false;
  var autoScreenshot = false;
  var screenshotDir : String;

  var currentShape : Int = 0;
  var shapeNames : Array<String>;
  var shapeLabels : Array<Text>;
  var selectedLabel : Text;

  static function main() {
    new Main();
  }

  override function init() {
    shader = new SDFObjectFarmShader();
    shader.selectedShape = currentShape;
    fx = new ScreenFx(shader);
    copy = new Copy();
    Window.getInstance().addEventTarget(onEvent);

    var progDir = Path.directory(Sys.programPath());
    var baseDir = Path.normalize(Path.join([progDir, "..", ".."])); // up from bin/ to HEAPS3D
    screenshotDir = Path.join([baseDir, "sc"]);

    trace("Program path: " + Sys.programPath());
    trace("Screenshot directory: " + screenshotDir);

    for (arg in Sys.args()) {
      if (arg == "--sc") {
        pendingScreenshot = true;
        autoScreenshot = true;
        trace("Auto-screenshot enabled via --sc flag");
      }
    }

    initUI();
  }

  function initUI() {
    shapeNames = [
      "Sphere", "Box", "Capsule", "Torus", "Cone",
      "Cylinder", "Ellipsoid", "Pyramid", "Plane",
      "HollowSphere", "HollowBox", "ShellCylinder"
    ];

    shapeLabels = [];
    var font = hxd.res.DefaultFont.get();
    var yPos = 20.0;

    // Title
    var title = new Text(font, s2d);
    title.text = "SDF SHAPES";
    title.x = 20;
    title.y = yPos;
    title.textColor = 0xFFFFFF;
    title.scale(1.5);
    yPos += 35;

    // Shape list
    for (i in 0...shapeNames.length) {
      var label = new Text(font, s2d);
      label.text = shapeNames[i];
      label.x = 20;
      label.y = yPos;
      label.textColor = i == currentShape ? 0xFFFF00 : 0xAAAAAA;
      label.scale(1.2);

      var bg = new Interactive(label.textWidth + 10, label.textHeight + 5, s2d);
      bg.x = label.x - 5;
      bg.y = label.y - 2;
      bg.backgroundColor = 0x000000;
      bg.alpha = 0.5;

      final shapeIndex = i;
      bg.onClick = function(_) selectShape(shapeIndex);
      bg.onOver = function(_) label.textColor = 0xFFFFFF;
      bg.onOut = function(_) label.textColor = (shapeIndex == currentShape) ? 0xFFFF00 : 0xAAAAAA;

      s2d.addChildAt(label, s2d.numChildren);
      shapeLabels.push(label);

      yPos += 25;
    }

    // Help text
    yPos += 20;
    var helpLines = [
      "CONTROLS:",
      "Click shape to select",
      "UP/DOWN - Prev/Next",
      "0-9 - Direct select",
      "Wheel - Zoom camera",
      "F12/P - Screenshot"
    ];

    for (line in helpLines) {
      var help = new Text(font, s2d);
      help.text = line;
      help.x = 20;
      help.y = yPos;
      help.textColor = line == "CONTROLS:" ? 0xCCCCCC : 0x888888;
      help.scale(0.9);
      yPos += 18;
    }
  }

  function selectShape(index:Int) {
    if (index == currentShape) return;

    shapeLabels[currentShape].textColor = 0xAAAAAA;
    currentShape = index;
    shapeLabels[currentShape].textColor = 0xFFFF00;
    shader.selectedShape = currentShape;

    trace("Selected shape: " + shapeNames[currentShape]);
  }

  override function update(dt:Float) {
    t += dt;
  }

  override function render(e:h3d.Engine) {
    shader.time = t;
    shader.resolution.set(e.width, e.height);

    var cam = computeCamera(t);
    shader.cameraPos.set(cam.pos.x, cam.pos.y, cam.pos.z);
    shader.cameraForward.set(cam.forward.x, cam.forward.y, cam.forward.z);
    shader.cameraRight.set(cam.right.x, cam.right.y, cam.right.z);
    shader.cameraUp.set(cam.up.x, cam.up.y, cam.up.z);

    if (pendingScreenshot) {
      // For screenshot: render to texture, capture, then display
      if (renderTarget == null || renderTarget.width != e.width || renderTarget.height != e.height) {
        if (renderTarget != null) renderTarget.dispose();
        renderTarget = new Texture(e.width, e.height, [Target]);
      }

      e.pushTarget(renderTarget);
      e.clear(0x000000);
      fx.render();
      e.popTarget();

      captureScreenshot(e);

      // Copy texture to screen
      copy.apply(renderTarget, null);
    } else {
      // Normal render: directly to screen
      e.clear(0x000000);
      fx.render();
    }
  }

  function computeCamera(time:Float):{pos:Vector, forward:Vector, right:Vector, up:Vector} {
    var angle = time * 0.25;
    var height = 0.4 + Math.sin(time * 0.6) * 0.15;
    var pos = new Vector(Math.sin(angle) * distance, height, Math.cos(angle) * distance);
    var forward = normalized(new Vector(-pos.x, -pos.y, -pos.z));
    var right = normalized(cross(forward, new Vector(0, 1, 0)));
    if (lengthSq(right) < 1e-6) right = new Vector(1, 0, 0);
    var up = cross(right, forward);
    return {pos: pos, forward: forward, right: right, up: up};
  }

  static inline function cross(a:Vector, b:Vector):Vector {
    return new Vector(
      a.y * b.z - a.z * b.y,
      a.z * b.x - a.x * b.z,
      a.x * b.y - a.y * b.x
    );
  }

  static inline function lengthSq(v:Vector):Float {
    return v.x * v.x + v.y * v.y + v.z * v.z;
  }

  static inline function normalized(v:Vector):Vector {
    var len = Math.sqrt(lengthSq(v));
    if (len < 1e-6) return new Vector(0, 0, 0);
    var inv = 1.0 / len;
    return new Vector(v.x * inv, v.y * inv, v.z * inv);
  }

  function onEvent(e:Event):Void {
    switch (e.kind) {
      case EKeyDown:
        if (e.keyCode == Key.F12 || e.keyCode == Key.P) {
          trace("Screenshot key pressed (F12 or P)");
          pendingScreenshot = true; // F12 primary, P fallback
        } else if (e.keyCode == Key.UP || e.keyCode == Key.LEFT) {
          selectShape((currentShape - 1 + shapeNames.length) % shapeNames.length);
        } else if (e.keyCode == Key.DOWN || e.keyCode == Key.RIGHT) {
          selectShape((currentShape + 1) % shapeNames.length);
        } else if (e.keyCode >= Key.NUMBER_0 && e.keyCode <= Key.NUMBER_9) {
          var num = e.keyCode - Key.NUMBER_0;
          if (num < shapeNames.length) selectShape(num);
        }
      case EWheel:
        var zoomFactor = Math.pow(0.9, e.wheelDelta);
        distance = clamp(distance * zoomFactor, 2.0, 12.0);
      default:
    }
  }

  function captureScreenshot(engine:h3d.Engine) {
    pendingScreenshot = false;
    try {
      trace("Attempting screenshot capture...");

      if (!FileSystem.exists(screenshotDir)) {
        trace("Creating screenshot directory: " + screenshotDir);
        FileSystem.createDirectory(screenshotDir);
      }

      // Capture pixels from render target texture instead of main buffer
      var pix = renderTarget.capturePixels();
      pix.convert(PixelFormat.RGBA);

      var stamp = Std.int(t * 1000);
      var fileName = "shot_" + stamp + ".png";
      var fullPath = Path.join([screenshotDir, fileName]);

      trace("Saving screenshot to: " + fullPath);
      File.saveBytes(fullPath, pix.toPNG());
      trace("Screenshot saved successfully!");

      if (autoScreenshot) Sys.exit(0);
    } catch (e:Dynamic) {
      trace("ERROR capturing screenshot: " + e);
    }
  }

  static inline function clamp(v:Float, lo:Float, hi:Float):Float {
    return v < lo ? lo : (v > hi ? hi : v);
  }
}
