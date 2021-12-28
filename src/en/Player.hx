package en;

import h2d.col.Point;
import objects.FlashLight;
import dn.heaps.Controller.ControllerAccess;

/**
 * Player class
 * that allows us to 
 * move around in the game. 
 * We can move around and also 
 * activate our flashlight.
 */
class Player extends BaseEnt {
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
    setupFlashLights();
    setupGraphics();
  }

  public function setupFlashLights() {
    flashLight = new FlashLight();
    this.spr.addChild(flashLight.lightG);
    flashLight.turnOff();
  }

  public function setupGraphics() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0xffa0ff);
    var size = Const.GRID;
    g.drawRect(0, 0, size, size);
    g.endFill();
  }

  override function update() {
    super.update();
    updateFlashLights();
    updateCollisions();
    updateControls();
  }

  public function updateFlashLights() {
    // Have Flashlight face the normal from player position to the mouse
    var scn = Boot.ME.s2d;
    var pos = spr.getAbsPos();
    // PlayerToMouse
    var pToM = new Point(scn.mouseX - pos.x, scn.mouseY - pos.y).normalized();

    flashLight.lightG.rotation = M.angTo(0, 0, pToM.x, pToM.y);
  }

  public function updateCollisions() {
    if (level != null) {
      collideWithEnemy();
      collideWithCollectible();
    }
  }

  public function collideWithEnemy() {
    var enemy = level.collidedEnemy(cx, cy);
    if (enemy != null) {
      var enemyT = Type.getClass(enemy);
      switch (enemyT) {
        case _:
          // Do nothing
      }
    }
  }

  public function collideWithCollectible() {
    var collectible = level.collidedCollectible(cx, cy);
    if (collectible != null) {
      var collectibleT = Type.getClass(collectible);
      switch (collectibleT) {
        case _:
          // Do nothing
      }
    }
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