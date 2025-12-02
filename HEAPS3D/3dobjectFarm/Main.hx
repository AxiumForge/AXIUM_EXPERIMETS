package;

import h3d.pass.ScreenFx;
import h3d.pass.Copy;
import h3d.Vector;
import h3d.mat.Texture;
import hxd.App;
import hxd.Event;
import hxd.Window;
import hxd.Key;
import Sys;
import StringTools;

// Module imports
import ShapeCatalog.ShapeCategory; // typedef from ShapeCatalog
import Shapes; // Barrel import - makes all 39 shape classes available for Type.resolveClass()

/**
  Main application - orchestrates engine, rendering, camera, and screenshot flow.
  UI handled by ShapePanel, shape registry by ShapeCatalog, screenshots by Screenshot utility.
**/
class Main extends App {

  // Core rendering
  var fx : ScreenFx<BaseRaymarchShader>;
  var shader : BaseRaymarchShader;
  var viewportTexture : Texture;
  var screenshotTexture : Texture;
  var copy : Copy;
  var t : Float = 0.0;
  var distance : Float = 5.0;

  // Shape management
  var shapePanel : ShapePanel;
  var shapeCategories : Array<ShapeCategory>;
  var shapeNames : Array<String>;
  var currentShape : Int = 0;

  // Screenshot flow
  var pendingScreenshot = false;
  var autoScreenshot = false;
  var screenshotDir : String;
  var shapesToScreenshot : Array<String> = [];
  var currentScreenshotIndex : Int = 0;
  var framesBeforeScreenshot : Int = 0;

  // Frame sequence screenshot flow
  var sequenceMode : Bool = false;
  var sequenceFrameCount : Int = 20;
  var currentSequenceFrame : Int = 0;
  var sequenceDir : String = "";
  var sequenceNumber : Int = 1;
  var timeBetweenFrames : Float = 1.0; // 1 second between frames = 20 second animation
  var timeOfLastFrame : Float = 0;

  // Viewport dimensions
  var viewportWidth : Int = 0;
  var viewportHeight : Int = 0;

  static function main() {
    new Main();
  }

  override function init() {
    // Load shape catalog
    shapeCategories = ShapeCatalog.defaultCategories();
    shapeNames = ShapeCatalog.shapeNames(shapeCategories);
    trace("Loaded " + shapeNames.length + " shapes in " + shapeCategories.length + " categories");

    // Setup initial shader
    shader = ShapeCatalog.createShaderForShape("Box", shapeCategories);
    fx = new ScreenFx(shader);
    copy = new Copy();
    Window.getInstance().addEventTarget(onEvent);

    // Setup screenshot directory
    screenshotDir = Screenshot.defaultDirFromProgramPath(Sys.programPath());
    trace("Program path: " + Sys.programPath());
    trace("Screenshot directory: " + screenshotDir);

    // Parse command line args for screenshot mode
    parseCommandLineArgs();
  }

  function parseCommandLineArgs():Void {
    var screenshotMode = false;
    var requestedShapes : Array<String> = [];

    for (arg in Sys.args()) {
      if (arg == "--sc") {
        screenshotMode = true;
        trace("Auto-screenshot enabled via --sc flag");
      } else if (arg == "--seq" || arg == "--sc-seq") {
        sequenceMode = true;
        trace("Frame sequence screenshot mode enabled");
      } else if (StringTools.startsWith(arg, "--")) {
        // Check if this arg matches any shape name (case-insensitive)
        var shapeName = arg.substring(2);
        for (name in shapeNames) {
          if (name.toLowerCase() == shapeName.toLowerCase()) {
            requestedShapes.push(name);
            trace("Found shape flag: " + name);
            break;
          }
        }
      }
    }

    // Handle frame sequence mode
    if (sequenceMode) {
      // Select shape if specified, otherwise use current shape
      if (requestedShapes.length > 0) {
        var shapeIndex = shapeNames.indexOf(requestedShapes[0]);
        if (shapeIndex >= 0) {
          selectShape(shapeIndex);
        }
      }

      // Setup sequence directory
      sequenceDir = Screenshot.sequenceDir(screenshotDir, sequenceNumber);
      trace("Frame sequence: capturing " + sequenceFrameCount + " frames of " + shapeNames[currentShape]);
      trace("Sequence directory: " + sequenceDir);

      currentSequenceFrame = 0;
      autoScreenshot = true;
      return;
    }

    // If --sc is set with shape flags, prepare screenshot sequence
    if (screenshotMode && requestedShapes.length > 0) {
      shapesToScreenshot = requestedShapes;
      currentScreenshotIndex = 0;
      autoScreenshot = true;

      // Switch to first requested shape
      var firstShapeIndex = shapeNames.indexOf(shapesToScreenshot[0]);
      if (firstShapeIndex >= 0) {
        selectShape(firstShapeIndex);
      }

      pendingScreenshot = true;
      framesBeforeScreenshot = 3;
      trace("Screenshot sequence: " + shapesToScreenshot.join(", "));
    } else if (screenshotMode) {
      // Just --sc without shapes: screenshot current shape
      pendingScreenshot = true;
      framesBeforeScreenshot = 3;
      autoScreenshot = true;
    }
  }

  override function onResize() {
    super.onResize();
    if (shapePanel != null) {
      shapePanel.onResize(s2d.width);
    }
  }

  function selectShape(index:Int):Void {
    if (index == currentShape) return;
    currentShape = index;

    // Create new shader for selected shape
    shader = ShapeCatalog.createShaderForShape(shapeNames[currentShape], shapeCategories);
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

    // Update UI if it exists
    if (shapePanel != null) {
      shapePanel.setCurrentShape(index);
    }
  }

  override function update(dt:Float) {
    t += dt;
  }

  override function render(e:h3d.Engine) {
    // Initialize UI on first render when we have proper dimensions
    if (shapePanel == null) {
      viewportWidth = e.width - 250; // panelWidth
      viewportHeight = e.height;
      shapePanel = new ShapePanel(s2d, shapeCategories, currentShape, selectShape);
    }

    // Update viewport dimensions
    viewportWidth = e.width - shapePanel.panelWidth;
    viewportHeight = e.height;

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

    // Handle frame sequence mode
    if (sequenceMode && currentSequenceFrame < sequenceFrameCount) {
      // Check if enough time has passed since last frame
      var timeSinceLastFrame = t - timeOfLastFrame;
      var shouldCaptureFrame = (currentSequenceFrame == 0) || (timeSinceLastFrame >= timeBetweenFrames);

      if (shouldCaptureFrame) {
        // Render full frame with UI to screenshot texture
        if (screenshotTexture == null || screenshotTexture.width != e.width || screenshotTexture.height != e.height) {
          if (screenshotTexture != null) screenshotTexture.dispose();
          screenshotTexture = new Texture(e.width, e.height, [Target]);
        }

        e.pushTarget(screenshotTexture);
        e.clear(0x000000);
        copy.apply(viewportTexture, null);
        s2d.render(e);
        e.popTarget();

        // Save frame using Screenshot.saveSequenceFrame()
        var savedPath = Screenshot.saveSequenceFrame(screenshotTexture, sequenceDir, currentSequenceFrame + 1, "frame_");
        trace("Saved frame " + (currentSequenceFrame + 1) + "/" + sequenceFrameCount + " at t=" + Math.round(t * 10) / 10 + "s");

        currentSequenceFrame++;
        timeOfLastFrame = t;

        // Exit when sequence complete
        if (currentSequenceFrame >= sequenceFrameCount) {
          trace("Frame sequence complete! Saved to: " + sequenceDir);
          trace("Total duration: " + Math.round(t * 10) / 10 + " seconds");
          Sys.exit(0);
        }

        // Display to screen
        e.clear(0x000000);
        copy.apply(screenshotTexture, null);
        return;
      }
    }

    // Handle frame delay before screenshot
    if (pendingScreenshot && framesBeforeScreenshot > 0) {
      framesBeforeScreenshot--;
      if (framesBeforeScreenshot > 0) {
        // Still waiting, just render normally
        e.clear(0x000000);
        copy.apply(viewportTexture, null);
        s2d.render(e);
        return;
      }
    }

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

      captureScreenshot();

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

  function captureScreenshot():Void {
    pendingScreenshot = false;

    try {
      trace("Attempting screenshot capture...");

      // Generate filename based on shape name if in sequence mode
      var fileName : String;
      if (shapesToScreenshot.length > 0 && currentScreenshotIndex < shapesToScreenshot.length) {
        fileName = shapesToScreenshot[currentScreenshotIndex] + ".png";
      } else {
        fileName = "shot_" + Std.int(t * 1000) + ".png";
      }

      // Use Screenshot utility to save texture
      Screenshot.saveWithName(screenshotTexture, screenshotDir, fileName, false);

      // Handle screenshot sequence
      if (shapesToScreenshot.length > 0) {
        currentScreenshotIndex++;

        if (currentScreenshotIndex < shapesToScreenshot.length) {
          // Move to next shape in sequence
          var nextShapeName = shapesToScreenshot[currentScreenshotIndex];
          var nextShapeIndex = shapeNames.indexOf(nextShapeName);

          if (nextShapeIndex >= 0) {
            trace("Moving to next shape: " + nextShapeName);
            selectShape(nextShapeIndex);

            // Queue next screenshot
            pendingScreenshot = true;
            framesBeforeScreenshot = 3;
          }
        } else {
          // Sequence complete
          trace("Screenshot sequence complete!");
          if (autoScreenshot) Sys.exit(0);
        }
      } else if (autoScreenshot) {
        // Single screenshot mode
        Sys.exit(0);
      }
    } catch (e:Dynamic) {
      trace("ERROR capturing screenshot: " + e);
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
    // Let ShapePanel handle UI events first
    if (shapePanel != null && shapePanel.handleEvent(e)) {
      return; // Event consumed by panel
    }

    // Handle non-UI events
    switch (e.kind) {
      case EKeyDown:
        if (e.keyCode == Key.F12 || e.keyCode == Key.P) {
          trace("Screenshot key pressed (F12 or P)");
          pendingScreenshot = true;
          framesBeforeScreenshot = 3;
        }
      case EWheel:
        // Zoom camera (if not over UI panel - already checked by shapePanel.handleEvent)
        var zoomFactor = Math.pow(0.9, e.wheelDelta);
        distance = clamp(distance * zoomFactor, 2.0, 12.0);
      default:
    }
  }

  static inline function clamp(v:Float, lo:Float, hi:Float):Float {
    return v < lo ? lo : (v > hi ? hi : v);
  }
}
