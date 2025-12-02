package;

import h3d.pass.ScreenFx;
import h3d.pass.Copy;
import h3d.Vector;
import h3d.mat.Texture;
import h2d.Text;
import h2d.Interactive;
import h2d.Graphics;
import h2d.Object;
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
  var uiPanel : Object;
  var scrollContainer : Object;
  var scrollOffset : Float = 0;
  var maxScroll : Float = 0;
  var shapeButtons : Array<{bg:Graphics, label:Text, interactive:Interactive}>;
  var panelWidth : Int = 250;
  var panelX : Float = 0;

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
  }

  override function onResize() {
    super.onResize();
    if (s2d != null) {
      panelX = s2d.width - panelWidth;
      if (uiPanel != null) initUI();
    }
  }

  function initUI() {
    // Clear previous UI if exists
    if (uiPanel != null) {
      s2d.removeChildren();
      shapeButtons = [];
    }

    shapeNames = [
      "Sphere", "Box", "Capsule", "Torus", "Cone",
      "Cylinder", "Ellipsoid", "Pyramid", "Plane",
      "HollowSphere", "HollowBox", "ShellCylinder"
    ];

    var font = hxd.res.DefaultFont.get();
    var panelHeight = Std.int(s2d.height);

    // Main panel background
    var panelBg = new Graphics(s2d);
    panelBg.beginFill(0x1a1a1a, 0.95);
    panelBg.drawRect(0, 0, panelWidth, panelHeight);
    panelBg.endFill();
    panelBg.x = panelX;

    // Title section
    var titleBg = new Graphics(s2d);
    titleBg.beginFill(0x333333);
    titleBg.drawRect(0, 0, panelWidth, 60);
    titleBg.endFill();
    titleBg.x = panelX;

    var title = new Text(font, s2d);
    title.text = "SDF SHAPES";
    title.textColor = 0xFFFFFF;
    title.scale(1.8);
    title.x = panelX + 15;
    title.y = 18;

    // Scrollable shape list container
    var scrollAreaHeight = panelHeight - 230; // Leave space for title and help
    scrollContainer = new Object(s2d);
    scrollContainer.x = panelX;
    scrollContainer.y = 70;

    shapeButtons = [];
    var btnWidth = panelWidth - 30;
    var yPos = 0.0;

    for (i in 0...shapeNames.length) {
      var btn = new Object(scrollContainer);
      btn.y = yPos;
      btn.x = 15;

      var bg = new Graphics(btn);
      bg.beginFill(i == currentShape ? 0x444444 : 0x2a2a2a);
      bg.drawRoundedRect(0, 0, btnWidth, 45, 5);
      bg.endFill();

      var label = new Text(font, btn);
      label.text = shapeNames[i];
      label.textColor = i == currentShape ? 0xFFFF00 : 0xCCCCCC;
      label.scale(1.3);
      label.x = 12;
      label.y = 12;

      var interactive = new Interactive(btnWidth, 45, btn);
      interactive.backgroundColor = 0x555555;
      interactive.alpha = 0;

      final shapeIndex = i;
      interactive.onClick = function(_) {
        selectShape(shapeIndex);
        refreshShapeButtons();
      };
      interactive.onOver = function(_) {
        bg.clear();
        bg.beginFill(0x555555);
        bg.drawRoundedRect(0, 0, btnWidth, 45, 5);
        bg.endFill();
      };
      interactive.onOut = function(_) {
        bg.clear();
        bg.beginFill(shapeIndex == currentShape ? 0x444444 : 0x2a2a2a);
        bg.drawRoundedRect(0, 0, btnWidth, 45, 5);
        bg.endFill();
      };

      shapeButtons.push({bg: bg, label: label, interactive: interactive});
      yPos += 50;
    }

    var scrollAreaHeight = panelHeight - 230;
    maxScroll = Math.max(0, yPos - scrollAreaHeight);

    uiPanel = new Object(s2d); // Mark UI as initialized

    // Help section at bottom
    var helpY = panelHeight - 160;
    var helpBg = new Graphics(s2d);
    helpBg.beginFill(0x2a2a2a);
    helpBg.drawRect(0, 0, panelWidth, 160);
    helpBg.endFill();
    helpBg.x = panelX;
    helpBg.y = helpY;

    var helpTitle = new Text(font, s2d);
    helpTitle.text = "CONTROLS";
    helpTitle.textColor = 0xCCCCCC;
    helpTitle.scale(1.2);
    helpTitle.x = panelX + 15;
    helpTitle.y = helpY + 15;

    var helpLines = [
      "Click: Select shape",
      "UP/DOWN: Navigate",
      "Mouse wheel: Scroll/Zoom",
      "F12 or P: Screenshot"
    ];

    var lineY = helpY + 45;
    for (line in helpLines) {
      var helpText = new Text(font, s2d);
      helpText.text = line;
      helpText.textColor = 0x999999;
      helpText.scale(0.95);
      helpText.x = panelX + 15;
      helpText.y = lineY;
      lineY += 22;
    }
  }

  function refreshShapeButtons() {
    for (i in 0...shapeButtons.length) {
      var btn = shapeButtons[i];
      var isSelected = i == currentShape;

      btn.bg.clear();
      btn.bg.beginFill(isSelected ? 0x444444 : 0x2a2a2a);
      btn.bg.drawRoundedRect(0, 0, 220, 45, 5);
      btn.bg.endFill();

      btn.label.textColor = isSelected ? 0xFFFF00 : 0xCCCCCC;
    }
  }

  function selectShape(index:Int) {
    if (index == currentShape) return;
    currentShape = index;
    shader.selectedShape = currentShape;
    trace("Selected shape: " + shapeNames[currentShape]);
  }

  override function update(dt:Float) {
    t += dt;
  }

  override function render(e:h3d.Engine) {
    // Initialize UI on first render when we have proper dimensions
    if (uiPanel == null) {
      panelX = e.width - panelWidth;
      initUI();
    }

    shader.time = t;
    shader.resolution.set(e.width, e.height);

    var cam = computeCamera(t);
    shader.cameraPos.set(cam.pos.x, cam.pos.y, cam.pos.z);
    shader.cameraForward.set(cam.forward.x, cam.forward.y, cam.forward.z);
    shader.cameraRight.set(cam.right.x, cam.right.y, cam.right.z);
    shader.cameraUp.set(cam.up.x, cam.up.y, cam.up.z);

    if (pendingScreenshot) {
      // For screenshot: render everything to texture (3D + 2D), then capture
      if (renderTarget == null || renderTarget.width != e.width || renderTarget.height != e.height) {
        if (renderTarget != null) renderTarget.dispose();
        renderTarget = new Texture(e.width, e.height, [Target]);
      }

      e.pushTarget(renderTarget);
      e.clear(0x000000);
      fx.render();
      s2d.render(e); // Render UI into texture too
      e.popTarget();

      // Capture the full frame (3D + UI)
      captureScreenshot(e);

      // Display on screen
      e.clear(0x000000);
      copy.apply(renderTarget, null);
    } else {
      // Normal render: 3D directly to screen, then 2D UI
      e.clear(0x000000);
      fx.render();
      s2d.render(e);
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
          refreshShapeButtons();
        } else if (e.keyCode == Key.DOWN || e.keyCode == Key.RIGHT) {
          selectShape((currentShape + 1) % shapeNames.length);
          refreshShapeButtons();
        } else if (e.keyCode >= Key.NUMBER_0 && e.keyCode <= Key.NUMBER_9) {
          var num = e.keyCode - Key.NUMBER_0;
          if (num < shapeNames.length) {
            selectShape(num);
            refreshShapeButtons();
          }
        }
      case EWheel:
        // Check if mouse is over UI panel
        var mouseX = s2d.mouseX;
        if (mouseX > s2d.width - 250) {
          // Scroll panel
          scrollOffset = clamp(scrollOffset - e.wheelDelta * 30, 0, maxScroll);
          scrollContainer.y = 70 - scrollOffset;
        } else {
          // Zoom camera
          var zoomFactor = Math.pow(0.9, e.wheelDelta);
          distance = clamp(distance * zoomFactor, 2.0, 12.0);
        }
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
