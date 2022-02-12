package en;

import GameTypes.Lens;
import dn.heaps.assets.Aseprite;
import h2d.col.Point;

class Enemy extends BaseEnt implements LitEntity {
  public var isInvincible(get, null):Bool;
  public var isLit:Bool;
  public var test:h2d.Graphics;
  public var complete:Bool;
  public var point:Point;
  public var tween:Tweenie;
  public var alpha:Float;
  public var lens:Lens;

  public static inline var INVINCBIBLE_TIME:Float = 3;

  public function get_isInvincible() {
    return cd.has('invincibleTime');
  }

  /**
   * An enemy within them.
   * X, Y coordinates are the coordinates within the grid of the game.
   * @param x 
   * @param y 
   */
  public function new(x:Int, y:Int) {
    super(x, y);
    isLit = false;
    this.spr.alpha = 0;
    this.complete = true;
    this.point = new Point(this.spr.x, this.spr.y);
    this.alpha = 0;
    setup();
  }

  public function setup() {
    // Setup element within the game
    setupGraphics();
  }

  public function setupGraphics() {
    var g = new h2d.Graphics(spr);
    var ase = hxd.Res.img.Wisp.toAseprite();
    var slib = Aseprite.convertToSLib(Const.FPS, ase);
    spr.set(slib);
    spr.anim.registerStateAnim('idle', 0);
    spr.setCenterRatio();
  }

  override function update() {
    super.update();
    updateInvincible();
    handleLightInteraction();
  }

  public function updateInvincible() {
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

  override function takeDamage(value:Int = 1) {
    if (!isInvincible) {
      super.takeDamage(value);
      cd.setS('invincibleTime', INVINCBIBLE_TIME);
      this.knockback();
    }
  }

  public function handleLightInteraction() {
    this.point.x = this.spr.x;
    this.point.y = this.spr.y;
    // Refactor later into the level update function
    if (!cd.has('lightTransition') && level.player != null
      && level.player.lightCollider != null) {
      var inCone = level.player.lightCollider.contains(this.point);
      if (!isLit && inCone && level.player.flashLight.isOn()) {
        isLit = true;
        complete = false;
        #if debug
        trace('create tween enemy');
        #end
        level.tw.createS(this.alpha, 1, TEase, 2).end(() -> {
          complete = true;
        });
        cd.setS('lightTransition', 2);
      } else if (isLit && !inCone) {
        isLit = false;
        complete = false;
        level.tw.createS(this.alpha, 0.2, TEase, 2).end(() -> {
          complete = true;
        });
        cd.setS('lightTransition', 2);
      }
    }
    if (this.spr != null) {
      this.spr.alpha = alpha;
    }
  }
}