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

  public var flashLightOff:Bool;

  public function new(x:Int, y:Int) {
    super(x, y);
    setup();
  }

  public function setup() {
    ct = Main.ME.controller.createAccess('player');
    setupStats();
    setupFlashLights();
    setupGraphics();
    game.camera.trackEntity(this, true);
  }

  public function setupStats() {
    this.health = 3;
  }

  public function setupFlashLights() {
    flashLight = new FlashLight(0xffa0ff);
    this.spr.addChild(flashLight.lightG);
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
        case en.collectibles.Health:
          addHealth(1);
          collectible.destroy();
        case en.collectibles.Battery:
          // Give back battery percentage to the max
          collectible.destroy();
          flashLight.batteryLife = 1.;
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
      } else if (!flashLight.isOn()) {
        flashLight.turnOn();
        flashLightOff = false;
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

  // Standard overrides
  override function takeDamage(value:Int = 1) {
    // Shake camera when the player takes damage.
    Game.ME.camera.shakeS(0.5, 0.5);
    super.takeDamage(value);
  }
}