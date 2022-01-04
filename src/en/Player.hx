package en;

import h2d.col.Polygon;
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

  public var lightCollider:h2d.col.Polygon;

  public function new(x:Int, y:Int) {
    super(x, y);
    setup();
  }

  public function setup() {
    ct = Main.ME.controller.createAccess('player');
    setupStats();
    setupFlashLights();
    setupGraphics();
  }

  public function setupStats() {
    this.health = 3;
  }

  public function setupFlashLights() {
    flashLight = new FlashLight(0xffa0ff);
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
    updateHUD();
    updateFlashLights();
    updateCollisions();
    updateControls();
  }

  public function updateHUD() {
    hud.invalidate();
  }

  public function updateFlashLights() {
    // Have Flashlight face the normal from player position to the mouse
    var scn = Boot.ME.s2d;
    var pos = spr.getAbsPos();
    // PlayerToMouse
    var pToM = new Point(scn.mouseX - pos.x, scn.mouseY - pos.y).normalized();
    var oldRotation = flashLight.lightG.rotation * 1;
    flashLight.lightG.rotation = M.angTo(0, 0, pToM.x, pToM.y);

    var col = new Polygon(flashLight.lightPolygon.points.map((p) -> {
      var pC = p.clone();

      // Always rotate first before doing any addition, order of operations matter
      pC.rotate(flashLight.lightG.rotation);
      pC.x += flashLight.lightG.getAbsPos().x;
      pC.y += flashLight.lightG.getAbsPos().y;
      return pC;
    }));
    // if (!cd.has('testT')) {
    //   cd.setS('testT', 3, () -> {
    //     var pC = col.points[0];
    //     var eC = col.points[col.points.length - 2];
    //     trace('${pC.x}, ${pC.y}');
    //     trace('${eC.x}, ${eC.y}');
    //     trace('Enemy ${a.x}, ${a.y}');
    //     trace(col.contains(new Point(a.x, a.y)));
    //   });
    // }
    lightCollider = col;
  }

  public function updateCollisions() {
    if (level != null) {
      // Test
      for (enemy in level.enemies) {
        if (level.collideWithLightEn(enemy)) {
          enemy.destroy();
        }
      }
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
          // Take damage
          this.takeDamage();
          // Do nothing
      }
    }
  }

  public function collideWithCollectible() {
    var collectible = level.collidedCollectible(cx, cy);
    if (collectible != null) {
      var collectibleT = Type.getClass(collectible);
      switch (collectibleT) {
        case en.collectibles.Battery:
          // Give back battery percentage to the max
          flashLight.batteryLife = 1.;
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

  // Standard overrides
  override function takeDamage(value:Int = 1) {
    // Shake camera when the player takes damage.
    Game.ME.camera.shakeS(0.5, 0.5);
    super.takeDamage(value);
  }
}