package en;

import dn.heaps.assets.Aseprite;

class Enemy extends BaseEnt {
  public var isInvincible(get, null):Bool;

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
}