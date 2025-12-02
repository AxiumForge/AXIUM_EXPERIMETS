package;

import h2d.Graphics;
import h2d.Interactive;
import h2d.Mask;
import h2d.Object;
import h2d.Text;
import hxd.res.DefaultFont;

/**
  Extracted sidepanel UI (buttons, scroll, headers) from Main.hx.
  Build with buildPanel(), refresh via refreshButtons(), scroll via scrollBy().
**/
class ShapePanel {
  public var panelWidth:Int;
  public var panelX:Float;
  public var maxScroll:Float = 0;
  public var scrollOffset:Float = 0;
  public var uiPanel:Object;
  public var scrollContainer:Object;
  public var shapeButtons:Array<{bg:Graphics, label:Text, interactive:Interactive}>;

  public function new(panelWidth:Int = 250) {
    this.panelWidth = panelWidth;
    this.panelX = 0;
    shapeButtons = [];
  }

  /**
    Build the panel UI.
    @param s2d The scene/root container
    @param categories Shape categories to render
    @param shapeNames Flat list of shape names
    @param currentShape Currently selected index
    @param panelHeight Height of the panel
    @param panelX X offset where the panel should render
    @param onSelect Callback when a shape is clicked (receives shape index)
  **/
  public function buildPanel(s2d:Object, categories:Array<ShapeCategory>, shapeNames:Array<String>, currentShape:Int, panelHeight:Int, panelX:Float, onSelect:Int->Void):Void {
    clearUI(s2d);

    this.panelX = panelX;
    var font = DefaultFont.get();

    // Panel background
    var panelBg = new Graphics(s2d);
    panelBg.beginFill(0x1a1a1a, 0.95);
    panelBg.drawRect(0, 0, panelWidth, panelHeight);
    panelBg.endFill();
    panelBg.x = panelX;

    // Title
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

    // Scrollable list
    var scrollAreaHeight = panelHeight - 230;
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

    for (category in categories) {
      var header = new Text(font, scrollContainer);
      header.text = category.name.toUpperCase();
      header.textColor = 0xFFFFFF;
      header.scale(1.1);
      header.x = 15;
      header.y = yPos + 5;
      yPos += 30;

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
          onSelect(btnIndex);
          refreshButtons(currentShape); // caller should refresh after updating state
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
    uiPanel = new Object(s2d);

    // Help box
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

  /** Refresh button colors after selection state changes. */
  public function refreshButtons(currentShape:Int):Void {
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

  /** Scroll the list by pixel delta (positive moves up). */
  public function scrollBy(delta:Float):Void {
    scrollOffset = clamp(scrollOffset + delta, 0, maxScroll);
    if (scrollContainer != null) {
      scrollContainer.y = -scrollOffset;
    }
  }

  private function clearUI(s2d:Object):Void {
    if (s2d != null) {
      s2d.removeChildren();
    }
    shapeButtons = [];
  }

  static inline function clamp(v:Float, lo:Float, hi:Float):Float {
    return v < lo ? lo : (v > hi ? hi : v);
  }
}
