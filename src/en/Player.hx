package en;

import objects.FlashLight;
import dn.heaps.Controller.ControllerAccess;

/**
 * Player class
 * that allows us to 
 * move around in the game. 
 * We can move around and also 
 * activate our flashlight.
 */
class Player extends Entity {
  public static inline var MOVE_SPD:Float = .2;

  public var ct:ControllerAccess;

  /**
   * Standard flashlight within the game
   * that just gives the player vision within a cone around them.
   */
  public var flashLight:FlashLight;

  public function new(x:Int, y:Int) {
    super(x, y);
    setup();
  }

  public function setup() {
    ct = Main.ME.controller.createAccess('player');
    setupGraphics();
  }

  public function setupFlashLights() {
    flashLight = new FlashLight();
  }

  public function setupGraphics() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0xffa0ff);
    g.drawRect(0, 0, 8, 8);
    g.endFill();
  }

  override function update() {
    super.update();
    updateControls();
  }

  public function updateControls() {
    var left = ct.leftDown();
    var right = ct.rightDown();
    var down = ct.downDown();
    var up = ct.upDown();

    if (left || right || down || up) {
      if (left) {
        dx = -MOVE_SPD;
      }

      if (right) {
        dx = MOVE_SPD;
      }

      if (down) {
        dy = MOVE_SPD;
      }

      if (up) {
        dy = -MOVE_SPD;
      }
    }
  }
}