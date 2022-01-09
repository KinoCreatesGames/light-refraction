package en;

import dn.heaps.assets.Aseprite;

class Enemy extends BaseEnt {
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
}