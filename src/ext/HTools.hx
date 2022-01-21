package ext;

import h2d.col.Point;
import h3d.shader.ScreenShader;
import h3d.Engine;
import aseprite.Aseprite;
import hxd.Pixels;
import h3d.Vector;
import dn.legacy.Controller;
import dn.legacy.Controller.ControllerAccess;
import h2d.Text.Align;
import GameTypes.Controllers;

/**
 * Align in the center.
 * @param text 
 */
inline function center(text:h2d.Text) {
  text.textAlign = Align.Center;
}

/**
 * Align to the left.
 * @param text 
 */
inline function left(text:h2d.Text) {
  text.textAlign = Align.Left;
}

/**
 * Align to the right.
 * @param text 
 */
inline function right(text:h2d.Text) {
  text.textAlign = Align.Right;
}

/**
 * Gets the alignment xMin value 
 * @param text 
 */
inline function alignCalcX(text:h2d.Text) {
  return text.getSize().xMin;
}

/**
 * Process multiple keys rather than one for convenience.
 * @param ct 
 * @param keys 
 */
inline function isAnyKeyPressed(ct:ControllerAccess, keys:Array<Int>) {
  return keys.exists((key) -> ct.isKeyboardPressed(key));
}

/**
 * Process multiple keys down rather than one for convenience.
 * @param ct 
 * @param keys 
 */
inline function isAnyKeyDown(ct:ControllerAccess, keys:Array<Int>) {
  return keys.exists((key) -> ct.isKeyboardDown(key));
}

/**
 * Returns the x, y coordinate 
 * in integer x, y texture space  
 * @param color 
 */
function findPixel(color:Int, collisionPixels:Pixels,
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
function isPixelCollide(x:Float, y:Float, color:Int, collisionPixels:Pixels,
    tex:h3d.mat.Texture) {
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

/**
 * Ase to SLIB that creates a
 * spritelib within the game from an aseprite file
 * for consumation for an HSprite class.
 * @param ase 
 * @param fps 
 */
inline function aseToSlib(ase:Aseprite, fps:Int) {
  return dn.heaps.assets.Aseprite.convertToSLib(fps, ase);
}

/**
 * 
 * Rendering engine pop and clear for when working
 * with render textures within the game for shader code.
 * ```
 * engine.popTarget()
 * engine.clear(color, depth);
 * ```
 */
inline function popClear(engine:Engine, color:Int = 0, ?depth:Float = 1,
    ?stencil:Int) {
  engine.popTarget();
  engine.clear(color, depth, stencil);
}

/**
 * Creates a screen shader with the texture property already set for the shader.
 * @param shader 
 */
inline function createScShader<T:ScreenShader>(shader:T) {
  return shader;
}

/**
 * Returns the absolute position of the sprite
 * as a single Heaps point object.
 * @param sprite 
 * @return Point
 */
inline function absPos(sprite:HSprite):Point {
  var matrix = sprite.getAbsPos();
  return new Point(matrix.x, matrix.y);
}

/**
 * Returns a point using grid coordinates
 * @param point 
 * @param gridFactor determines if we should scale the point to the grid sprite coordinates
 */
inline function LDPtoPoint(point:ldtk.Point, gridFactor = 1) {
  return new Point(point.cx * gridFactor, point.cy * gridFactor);
}

inline function toVec(point:h2d.col.Point):Vector {
  return new Vector(point.x, point.y);
}