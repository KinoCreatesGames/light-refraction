package ext;

import hxd.Pixels;
import h3d.Vector;
import dn.heaps.Controller.ControllerAccess;
import h2d.Text.Align;

class HTools {
  public static inline function center(text:h2d.Text) {
    text.textAlign = Align.Center;
  }

  public static inline function left(text:h2d.Text) {
    text.textAlign = Align.Left;
  }

  public static inline function right(text:h2d.Text) {
    text.textAlign = Align.Right;
  }

  /**
   * Gets the alignment xMin value 
   * @param text 
   */
  public static inline function alignCalcX(text:h2d.Text) {
    return text.getSize().xMin;
  }

  /**
   * Process multiple keys rather than one for convenience.
   * @param ct 
   * @param keys 
   */
  public static inline function isAnyKeyPressed(ct:ControllerAccess,
      keys:Array<Int>) {
    return keys.exists((key) -> ct.isKeyboardPressed(key));
  }

  /**
   * Process multiple keys down rather than one for convenience.
   * @param ct 
   * @param keys 
   */
  public static inline function isAnyKeyDown(ct:ControllerAccess,
      keys:Array<Int>) {
    return keys.exists((key) -> ct.isKeyboardDown(key));
  }

  /**
   * Returns the x, y coordinate 
   * in integer x, y texture space  
   * @param color 
   */
  public static function findPixel(color:Int, collisionPixels:Pixels,
      collisionMap:h3d.mat.Texture) {
    var vec = Vector.fromColor(color);
    vec.a = 1.;
    for (x in 0...collisionPixels.width) {
      for (y in 0...collisionMap.height) {
        var colMapColor = (collisionPixels.getPixelF(x, y));
        if (vec.equals(colMapColor)) {
          return new Vector(x, y);
        }
      }
    }
    return null;
  }

  /**
   * Takes the world position in floating point
   * compares to the pixel coordinate 
   * @param x 
   * @param y 
   */
  public static function isPixelCollide(x:Float, y:Float, color:Int,
      collisionPixels:Pixels, tex:h3d.mat.Texture) {
    var width = tex.width;
    var height = tex.height;
    // var x = (mode.worldPos.x % 1.);
    // var y = (mode.worldPos.y % 1.);
    var pX = Std.int((x * width));
    var pY = Std.int((y * height));
    var colMapColor = (collisionPixels.getPixelF(pX, pY));
    var vec = Vector.fromColor(color);
    // Note that the alpha channel coming from the pixels is 1
    // Ends up being 0 from the vector from color we have to account for that;
    vec.a = 1.;
    return vec.equals(colMapColor);
  }
}