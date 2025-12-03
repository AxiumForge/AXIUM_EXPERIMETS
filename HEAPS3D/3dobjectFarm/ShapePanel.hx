package;

import h2d.Text;
import h2d.Interactive;
import h2d.Graphics;
import h2d.Object;
import h2d.Mask;
import h2d.Scene;
import hxd.Event;
import hxd.Key;
import ShapeCatalog.ShapeCategory;
import Shapes; // Barrel import - ensures all shapes available

/**
  Side panel UI for shape selection.
  Extracted from Main.hx to keep UI logic separate from core rendering.
**/
class ShapePanel {

  public var panelWidth(default, null):Int = 250;
  public var panelX(default, null):Float = 0;

  var s2d:Scene;
  var shapeNames:Array<String>;
  var shapeCategories:Array<ShapeCategory>;
  var currentShape:Int;
  var onShapeSelected:Int->Void;

  var uiPanel:Object;
  var scrollContainer:Object;
  var scrollOffset:Float = 0;
  var maxScroll:Float = 0;
  var shapeButtons:Array<{bg:Graphics, label:Text, interactive:Interactive}>;
  var alphaText:Text;

  /**
    Create the shape panel.
    - s2d: The 2D scene to render UI into
    - categories: Shape categories to display
    - initialShape: Index of initially selected shape
    - onShapeSelected: Callback when user selects a shape
  **/
  public function new(s2d:Scene, categories:Array<ShapeCategory>, initialShape:Int, onShapeSelected:Int->Void) {
    this.s2d = s2d;
    this.shapeCategories = categories;
    this.currentShape = initialShape;
    this.onShapeSelected = onShapeSelected;

    // Flatten shape names
    this.shapeNames = ShapeCatalog.shapeNames(categories);

    initUI();
  }

  /** Update panel position when window resizes. */
  public function onResize(sceneWidth:Int):Void {
    panelX = sceneWidth - panelWidth;
    if (uiPanel != null) initUI();
  }

  /** Set the currently selected shape (updates UI visuals). */
  public function setCurrentShape(index:Int):Void {
    if (index == currentShape) return;
    currentShape = index;
    refreshShapeButtons();
  }

  /** Update alpha display text. */
  public function setAlpha(alpha:Float):Void {
    if (alphaText != null) {
      alphaText.text = "Alpha: " + Math.round(alpha * 100) + "%";
    }
  }

  /** Handle keyboard/mouse events relevant to the panel. Returns true if event was consumed. */
  public function handleEvent(e:Event):Bool {
    switch (e.kind) {
      case EKeyDown:
        if (e.keyCode == Key.UP) {
          var newIndex = (currentShape - 1 + shapeNames.length) % shapeNames.length;
          currentShape = newIndex;
          onShapeSelected(newIndex);
          refreshShapeButtons();
          return true;
        } else if (e.keyCode == Key.DOWN) {
          var newIndex = (currentShape + 1) % shapeNames.length;
          currentShape = newIndex;
          onShapeSelected(newIndex);
          refreshShapeButtons();
          return true;
        } else if (e.keyCode >= Key.NUMBER_0 && e.keyCode <= Key.NUMBER_9) {
          var num = e.keyCode - Key.NUMBER_0;
          if (num < shapeNames.length) {
            currentShape = num;
            onShapeSelected(num);
            refreshShapeButtons();
            return true;
          }
        }
      case EWheel:
        // Check if mouse is over UI panel
        var mouseX = s2d.mouseX;
        if (mouseX > panelX) {
          // Scroll panel
          scrollOffset = clamp(scrollOffset - e.wheelDelta * 30, 0, maxScroll);
          scrollContainer.y = -scrollOffset;
          return true;
        }
      default:
    }
    return false;
  }

  function initUI():Void {
    // Clear previous UI if exists
    if (uiPanel != null) {
      s2d.removeChildren();
      shapeButtons = [];
    }

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
    var scrollAreaHeight = panelHeight - 250; // Leave space for title and help (180) + title (60) + padding (10)
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
          currentShape = btnIndex;
          onShapeSelected(btnIndex);
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

    maxScroll = Math.max(0, yPos - scrollAreaHeight);
    uiPanel = new Object(s2d); // Mark UI as initialized

    // Help section at bottom (increased height for alpha display)
    var helpY = panelHeight - 180;
    var helpBg = new Graphics(s2d);
    helpBg.beginFill(0x2a2a2a);
    helpBg.drawRect(0, 0, panelWidth, 180);
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
      "UP/DOWN: Navigate shapes",
      "LEFT/RIGHT: Alpha -/+",
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

    // Alpha display with background - positioned above help lines
    var alphaY = helpY + 130; // Position it higher up in the help section
    var alphaBg = new Graphics(s2d);
    alphaBg.beginFill(0x444444);
    alphaBg.drawRoundedRect(0, 0, panelWidth - 30, 35, 5);
    alphaBg.endFill();
    alphaBg.x = panelX + 15;
    alphaBg.y = alphaY;

    alphaText = new Text(font, s2d);
    alphaText.text = "Alpha: 100%";
    alphaText.textColor = 0x00FF00; // Bright green
    alphaText.scale(1.4);
    alphaText.x = panelX + 25;
    alphaText.y = alphaY + 7;
  }

  function refreshShapeButtons():Void {
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

  static inline function clamp(v:Float, lo:Float, hi:Float):Float {
    return v < lo ? lo : (v > hi ? hi : v);
  }
}
