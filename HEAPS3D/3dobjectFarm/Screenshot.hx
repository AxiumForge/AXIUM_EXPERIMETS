package;

import h3d.mat.Texture;
import hxd.PixelFormat;
import hxd.Pixels;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import StringTools;

/**
  Utility for saving framebuffer/texture screenshots.
  Standalone so Main.hx can pull this in after refaktor.
**/
class Screenshot {

  /** Returns the default screenshot directory (../sc from compiled bin/ location). */
  public static function defaultDirFromProgramPath(progPath:String):String {
    var progDir = Path.directory(progPath);
    var baseDir = Path.normalize(Path.join([progDir, "..", ".."])); // up from bin/ to HEAPS3D
    return Path.join([baseDir, "sc"]);
  }

  /** Ensures the directory exists. */
  public static function ensureDir(dir:String):Void {
    if (!FileSystem.exists(dir)) {
      FileSystem.createDirectory(dir);
    }
  }

  /** Returns a sequence subfolder path like "<dir>/sequence-01" and ensures it exists. */
  public static function sequenceDir(dir:String, sequence:Int):String {
    var padded = StringTools.lpad(Std.string(sequence), "0", 2);
    var seqPath = Path.join([dir, "sequence-" + padded]);
    ensureDir(seqPath);
    return seqPath;
  }

  /**
    Save a texture to PNG with a timestamp-based filename.
    - texture: the render target containing the final frame (UI included if desired)
    - dir: destination directory
    - stampMs: optional timestamp in ms (defaults to current time)
    - prefix: filename prefix (default: "shot_")
    - autoExit: if true, calls Sys.exit(0) after saving (useful for scripted captures)
  **/
  public static function saveTexture(texture:Texture, dir:String, ?stampMs:Int, prefix:String = "shot_", autoExit:Bool = false):Void {
    ensureDir(dir);

    var pix:Pixels = texture.capturePixels();
    pix.convert(PixelFormat.RGBA);

    var stamp = stampMs != null ? stampMs : Std.int(haxe.Timer.stamp() * 1000);
    var fileName = prefix + stamp + ".png";
    var fullPath = Path.join([dir, fileName]);

    File.saveBytes(fullPath, pix.toPNG());

    if (autoExit) {
      Sys.exit(0);
    }
  }

  /**
    Save a texture as part of a numbered sequence (frame_0001.png, etc.).
    - texture: render target to save
    - seqDir: directory for this sequence (create via sequenceDir)
    - frameIndex: 0-based or 1-based frame number
    - prefix: filename prefix (default: "frame_")
    Returns the full path to the saved file.
  **/
  public static function saveSequenceFrame(texture:Texture, seqDir:String, frameIndex:Int, prefix:String = "frame_"):String {
    ensureDir(seqDir);

    var pix:Pixels = texture.capturePixels();
    pix.convert(PixelFormat.RGBA);

    var fileName = prefix + StringTools.lpad(Std.string(frameIndex), "0", 4) + ".png";
    var fullPath = Path.join([seqDir, fileName]);
    File.saveBytes(fullPath, pix.toPNG());
    return fullPath;
  }
}
