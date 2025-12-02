package;

import h3d.pass.ScreenFx;
import h3d.pass.Copy;
import h3d.Vector;
import h3d.mat.Texture;
import h2d.Text;
import h2d.Interactive;
import h2d.Graphics;
import h2d.Object;
import h2d.Mask;
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
import StringTools;

// Shape shader imports
import obj.primitives.Box;
import obj.primitives.Sphere;
import obj.primitives.Capsule;
import obj.primitives.Cone;
import obj.primitives.Cylinder;
import obj.primitives.Ellipsoid;
import obj.primitives.Plane;
import obj.primitives.Pyramid;
import obj.primitives.Torus;
import obj.primitives2d.Box2D;
import obj.primitives2d.Circle;
import obj.primitives2d.Heart;
import obj.primitives2d.RoundedBox2D;
import obj.primitives2d.Star;
import obj.derivates.HalfCapsule;
import obj.derivates.HoledPlane;
import obj.derivates.HollowBox;
import obj.derivates.HollowSphere;
import obj.derivates.QuarterTorus;
import obj.derivates.ShellCylinder;

class Main extends App {

  var fx : ScreenFx<BaseRaymarchShader>;
  var shader : BaseRaymarchShader;
  var viewportTexture : Texture;
  var screenshotTexture : Texture;
  var copy : Copy;
  var t : Float = 0.0;
  var distance : Float = 5.0;
  var pendingScreenshot = false;
  var autoScreenshot = false;
  var screenshotDir : String;

  var currentShape : Int = 0;
  var shapeNames : Array<String>;
  var shapeCategories : Array<{name:String, shapes:Array<String>, package:String}>;
  var uiPanel : Object;
  var scrollContainer : Object;
  var scrollOffset : Float = 0;
  var maxScroll : Float = 0;
  var shapeButtons : Array<{bg:Graphics, label:Text, interactive:Interactive}>;
  var panelWidth : Int = 250;
  var panelX : Float = 0;
  var viewportWidth : Int = 0;
  var viewportHeight : Int = 0;

  static function main() {
    new Main();
  }

  override function init() {
    shader = createShaderForShape("Box"); // Start with Box
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

  function scanShapesFromFolder() {
    // All shapes hardcoded at compile time from obj/ folder
    useDefaultShapes();
    trace("Loaded " + shapeNames.length + " shapes in " + shapeCategories.length + " categories");
  }

  function useDefaultShapes() {
    shapeCategories = [
      {name: "Primitives", shapes: ["Box", "Capsule", "Cone", "Cylinder", "Ellipsoid", "Plane", "Pyramid", "Sphere", "Torus"], package: "obj.primitives"},
      {name: "2D Primitives", shapes: ["Box2D", "Circle", "Heart", "RoundedBox2D", "Star"], package: "obj.primitives2d"},
      {name: "Derivates", shapes: ["HalfCapsule", "HoledPlane", "HollowBox", "HollowSphere", "QuarterTorus", "ShellCylinder"], package: "obj.derivates"},
      {name: "2D Organics", shapes: ["FlowerPetalRing", "LeafPair", "LeafSpiral", "LotusFringe", "OrnateKnot", "SpiralVine", "VineCurl"], package: "obj._2DOrganics"},
      {name: "3D Organic", shapes: ["BlobbyCluster", "BubbleCrown", "BulbTreeCrown", "DripCone", "JellyDonut", "KnotTube", "MeltedBox", "PuffyCross", "RibbonTwist", "SoftSphereWrap", "UndulatingPlane", "WavyCapsule"], package: "obj._3dOrganic"}
    ];

    shapeNames = [];
    for (cat in shapeCategories) {
      for (shape in cat.shapes) {
        shapeNames.push(shape);
      }
    }
  }

  function initUI() {
    // Clear previous UI if exists
    if (uiPanel != null) {
      s2d.removeChildren();
      shapeButtons = [];
    }

    // Scan obj/ folder for shapes
    scanShapesFromFolder();

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

    // Scrollable shape list container with masking
    var scrollAreaHeight = panelHeight - 230; // Leave space for title and help
    var scrollMask = new Mask(panelWidth - 20, scrollAreaHeight, s2d);
    scrollMask.x = panelX + 10;
    scrollMask.y = 70;

    scrollContainer = new Object(scrollMask);
    scrollContainer.x = 0;
    scrollContainer.y = 0;

    shapeButtons = [];
    var btnWidth = panelWidth - 30;
    var yPos = 0.0;
    var shapeIndex = 0;

    // Build shape list with category headers
    for (category in shapeCategories) {
      // Category header
      var header = new Text(font, scrollContainer);
      header.text = category.name.toUpperCase();
      header.textColor = 0xFFFFFF;
      header.scale(1.1);
      header.x = 15;
      header.y = yPos + 5;
      yPos += 30;

      // Category shapes
      for (shapeName in category.shapes) {
        var btn = new Object(scrollContainer);
        btn.y = yPos;
        btn.x = 15;

        var bg = new Graphics(btn);
        bg.beginFill(shapeIndex == currentShape ? 0x444444 : 0x2a2a2a);
        bg.drawRoundedRect(0, 0, btnWidth, 45, 5);
        bg.endFill();

        var label = new Text(font, btn);
        label.text = shapeName;
        label.textColor = shapeIndex == currentShape ? 0xFFFF00 : 0xCCCCCC;
        label.scale(1.3);
        label.x = 12;
        label.y = 12;

        var interactive = new Interactive(btnWidth, 45, btn);
        interactive.backgroundColor = 0x555555;
        interactive.alpha = 0;

        final btnIndex = shapeIndex;
        interactive.onClick = function(_) {
          selectShape(btnIndex);
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
          bg.beginFill(btnIndex == currentShape ? 0x444444 : 0x2a2a2a);
          bg.drawRoundedRect(0, 0, btnWidth, 45, 5);
          bg.endFill();
        };

        shapeButtons.push({bg: bg, label: label, interactive: interactive});
        yPos += 50;
        shapeIndex++;
      }
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
    var btnWidth = panelWidth - 30;
    for (i in 0...shapeButtons.length) {
      var btn = shapeButtons[i];
      var isSelected = i == currentShape;

      btn.bg.clear();
      btn.bg.beginFill(isSelected ? 0x444444 : 0x2a2a2a);
      btn.bg.drawRoundedRect(0, 0, btnWidth, 45, 5);
      btn.bg.endFill();

      btn.label.textColor = isSelected ? 0xFFFF00 : 0xCCCCCC;
    }
  }

  function createShaderForShape(name:String):BaseRaymarchShader {
    // Find which category this shape belongs to
    for (cat in shapeCategories) {
      for (shapeName in cat.shapes) {
        if (shapeName == name) {
          // Build fully qualified class name: package.ShapeNameShader
          var className = cat.package + "." + name + "Shader";
          var cls = Type.resolveClass(className);

          if (cls != null) {
            var instance = Type.createInstance(cls, []);
            trace("Created shader: " + className);
            return cast instance;
          } else {
            trace("ERROR: Could not resolve shader class: " + className);
          }
        }
      }
    }

    // Fallback to Sphere if not found
    trace("WARNING: Shape '" + name + "' not found, using SphereShader as fallback");
    return new SphereShader();
  }

  function selectShape(index:Int) {
    if (index == currentShape) return;
    currentShape = index;

    // Create new shader for selected shape
    shader = createShaderForShape(shapeNames[currentShape]);
    shader.time = t;
    shader.resolution.set(viewportWidth, viewportHeight);

    // Update camera uniforms
    var cam = computeCamera(t);
    shader.cameraPos.set(cam.pos.x, cam.pos.y, cam.pos.z);
    shader.cameraForward.set(cam.forward.x, cam.forward.y, cam.forward.z);
    shader.cameraRight.set(cam.right.x, cam.right.y, cam.right.z);
    shader.cameraUp.set(cam.up.x, cam.up.y, cam.up.z);

    // Recreate ScreenFx with new shader
    fx.dispose();
    fx = new ScreenFx(shader);

    trace("Selected shape: " + shapeNames[currentShape]);
  }

  override function update(dt:Float) {
    t += dt;
  }

  override function render(e:h3d.Engine) {
    // Initialize UI on first render when we have proper dimensions
    if (uiPanel == null) {
      viewportWidth = e.width - panelWidth;
      viewportHeight = e.height;
      panelX = viewportWidth;
      initUI();
    }

    // Update viewport dimensions
    viewportWidth = e.width - panelWidth;
    viewportHeight = e.height;
    panelX = viewportWidth;

    // Update shader uniforms every frame
    shader.time = t;
    shader.resolution.set(viewportWidth, viewportHeight);

    var cam = computeCamera(t);
    shader.cameraPos.set(cam.pos.x, cam.pos.y, cam.pos.z);
    shader.cameraForward.set(cam.forward.x, cam.forward.y, cam.forward.z);
    shader.cameraRight.set(cam.right.x, cam.right.y, cam.right.z);
    shader.cameraUp.set(cam.up.x, cam.up.y, cam.up.z);

    // Render 3D to viewport texture
    if (viewportTexture == null || viewportTexture.width != viewportWidth || viewportTexture.height != viewportHeight) {
      if (viewportTexture != null) viewportTexture.dispose();
      viewportTexture = new Texture(viewportWidth, viewportHeight, [Target]);
    }

    e.pushTarget(viewportTexture);
    e.clear(0x000000);
    fx.render();
    e.popTarget();

    if (pendingScreenshot) {
      // For screenshot: render everything to full texture
      if (screenshotTexture == null || screenshotTexture.width != e.width || screenshotTexture.height != e.height) {
        if (screenshotTexture != null) screenshotTexture.dispose();
        screenshotTexture = new Texture(e.width, e.height, [Target]);
      }

      e.pushTarget(screenshotTexture);
      e.clear(0x000000);

      // Blit 3D viewport to left side
      copy.apply(viewportTexture, null);

      // Render UI panel
      s2d.render(e);
      e.popTarget();

      captureScreenshot(e);

      // Display to screen
      e.clear(0x000000);
      copy.apply(screenshotTexture, null);
    } else {
      // Normal render: Blit 3D viewport + render UI
      e.clear(0x000000);
      copy.apply(viewportTexture, null);
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
        if (mouseX > panelX) {
          // Scroll panel
          scrollOffset = clamp(scrollOffset - e.wheelDelta * 30, 0, maxScroll);
          scrollContainer.y = -scrollOffset;
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

      // Capture pixels from screenshot texture (full frame with UI)
      var pix = screenshotTexture.capturePixels();
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
