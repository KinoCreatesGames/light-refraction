package en;

import system.FlashLight;
import h2d.col.Polygon;
import h2d.col.Point;
import GameTypes.Controllers;
import dn.legacy.Controller;
import dn.legacy.Controller.ControllerAccess;

/**
 * Player class
 * that allows us to 
 * move around in the game. 
 * We can move around and also 
 * activate our flashlight.
 */
class Player extends BaseEnt {
  public static inline var MOVE_SPD:Float = .1;
  public static inline var FALL_TIME:Float = 2.2;
  public static inline var INVINCBIBLE_TIME:Float = 3;

  public var isInvincible(get, null):Bool;

  public inline function get_isInvincible() {
    return cd.has('invincibleTime');
  }

  public var ct:ControllerAccess;

  /**
   * In gamey keys that are within your posession.
   */
  public var keys:Int;

  /**
   * Standard flashlight within the game
   * that just gives the player vision within a cone around them.
   */
  public var flashLight:FlashLight;

  public var lightCollider:h2d.col.Polygon;

  public var flashLightOff:Bool;

  public var listener:EventListener<Player>;

  /**
   * The last safe position of the player, before stepping into a zone
   * where there is no floor. This area is the area
   * that would trigger a fall and return the player to a previous safe
   * position.
   */
  public var lastSafePos:Point;

  public function new(x:Int, y:Int) {
    super(x, y);
    setup();
  }

  public function setup() {
    ct = Main.ME.controller.createAccess('player');
    listener = EventListener.create();
    setupStats();
    // setupFlashLights(); //Moved to be set up during the level process
    setupGraphics();
    game.camera.trackEntity(this, true);
  }

  public function setupStats() {
    this.health = 3;
  }

  public function setupFlashLights(flashlight:system.FlashLight) {
    this.flashLight = flashlight;
    // this.spr.addChild(flashLight.lightG);
    // Renders flashlight on the same layer as everything else.
    Game.ME.scroller.add(flashLight.lightG, Const.DP_MAIN);
    flashLight.turnOff();
    flashLightOff = !flashLight.isOn();
  }

  public function setupGraphics() {
    var g = new h2d.Graphics(spr);
    var tile = hxd.Res.img.MCBasePNG.toTile();
    g.beginTileFill(0, 0, 1, 1, tile);
    // var size = Const.GRID;
    g.drawTile(0, 0, tile);
    g.endFill();
    // Offset Player
    g.x -= 32;
    g.y -= 32;
  }

  override function update() {
    super.update();
    updateInvincibility();
    updateHUD();
    updateFlashLights();
    updateCollisions();
    if (!cd.has('knockback')) {
      updateControls();
    }
  }

  /**
   * Updates the invincibility of the sprite
   * using the blinking capability.
   */
  public function updateInvincibility() {
    if (isInvincible) {
      // spr.alpha = 1;
      if (!cd.has('invincible')) {
        cd.setF('invincible', 5, () -> {
          spr.alpha = 0;
        });
      } else {
        spr.alpha = 1;
      }
    } else {
      spr.alpha = 1;
    }
  }

  public function updateHUD() {
    hud.invalidate();
  }

  public function updateFlashLights() {
    flashLight.update();
    // Update the light poly with the absolute position
    // of the elements within the game.
    var abs = this.spr.absPos();
    if (flashLight.isOn()) {
      hud.pingActive();
    }

    lightCollider = new Polygon(flashLight.lightPoly.points);
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
      collideWithExit();
    }
  }

  public function collideWithEnemy() {
    var enemy = level.collidedEnemy(cx, cy);
    if (enemy != null) {
      var enemyT = Type.getClass(enemy);
      switch (enemyT) {
        case _:
          // Take damage
          enemy.kill(this);
          this.takeDamage();
          hud.pingActive();
          // Do nothing
      }
    }
  }

  public function collideWithCollectible() {
    var collectible = level.collidedCollectible(cx, cy);
    if (collectible != null) {
      var collectibleT = Type.getClass(collectible);
      switch (collectibleT) {
        case en.collectibles.Health:
          addHealth(1);
          collectible.destroy();
          Assets.collectSnd.play();
        case en.collectibles.Battery:
          // Give back battery percentage to the max
          collectible.destroy();
          flashLight.batteryLife = 1.;
          Assets.collectSnd.play();
        case en.collectibles.Key:
          collectible.destroy();
          keys += 1;
          Assets.collectSnd.play();
        case _:
          // Do nothing
      }
    }
  }

  public function collideWithExit() {
    var collided = level.hasExitCollision(cx, cy);
    if (collided != null) {
      level.transferPlayer(cast collided);
    }
  }

  public function updateControls() {
    var left = ct.leftDown();
    var right = ct.rightDown();
    var down = ct.downDown();
    var up = ct.upDown();
    var cancel = ct.bDown();
    if (cancel && !cd.has('lightCD')) {
      if (flashLight.isOn()) {
        flashLight.turnOff();
        flashLightOff = true;
        Assets.switchOffSnd.play();
      } else if (!flashLight.isOn()) {
        flashLight.turnOn();
        flashLightOff = false;
        Assets.switchOnSnd.play();
      }
      cd.setS('lightCD', 0.2);
    }

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

  override function onPreStepX() {
    super.onPreStepX();
    // Left
    if (level.hasAnyCollision(cx - 1, cy) && xr <= 0.3) {
      xr = 0.3;
      dx = 0;
      setSquashX(0.6);
      // dx = M.fabs(dx);
    }

    // Right
    if (level.hasAnyCollision(cx + 1, cy) && xr >= 0.1) {
      // push back to previous cell
      xr = 0.1;
      dx = 0;
      setSquashX(0.6);
      // dx = (-1 * M.fabs(dx));
    }
  }

  override function onPreStepY() {
    super.onPreStepY();
    // if (level.hasAnyCollision(cx, cy + 1)
    //   && yr >= 0.5
    //   || level.hasAnyCollision(cx + M.round(xr), cy + 1)
    //   && yr >= 0.5) {
    //   // Handle squash and stretch for entities in the game
    //   if (level.hasAnyCollision(cx, cy + M.round(yr + 0.3))) {
    //     setSquashY(0.6);
    //     dy = 0;
    //   }
    //   yr = 0.3;
    //   dy = 0;
    // }

    // if (level.hasAnyCollision(cx, cy + 1)) {
    //   // setSquashY(0.6);
    //   yr = -0.1;
    //   dy = -0.1;
    // }

    // if (level.hasAnyCollision(cx, cy - 1)) {
    //   yr = 1.01;
    //   dy = .1;
    //   // setSquashY(0.6);
    // }
  }

  /**
   * Triggers a fall and sends the player 
   * back to the previous safe position.
   */
  public function fall() {
    cd.setS('falling', FALL_TIME, () -> {
      // Return to safety
      // Play falling animation for the player sprite.
      returnToSafety();
    });
  }

  /**
   * Returns to the lat safe position
   */
  public function returnToSafety() {}

  // Standard overrides
  override function takeDamage(value:Int = 1) {
    // Shake camera when the player takes damage.
    if (!isInvincible) {
      Game.ME.camera.shakeS(0.5, 0.5);
      super.takeDamage(value);
      cd.setS('invincibleTime', INVINCBIBLE_TIME);
      this.knockback();
      Assets.damageSnd.play();
    }
  }
}