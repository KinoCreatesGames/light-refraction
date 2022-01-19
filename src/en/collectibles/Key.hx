package en.collectibles;

import h2d.filter.Nothing;
import h2d.filter.ColorMatrix;

/**
 * Key that opens up locked doors within the game
 * using them consumes them forever and they can't be used agai.
 * within the game.
 */
class Key extends Collectible {
  public function new(eKey:Entity_GameKey) {
    super(eKey.cx, eKey.cy);
  }

  override function setupGraphic() {
    super.setupGraphic();
    spr.filter = new Nothing();
    var g = new h2d.Graphics(this.spr);
    g.beginFill(0xffaa00);
    g.drawCircle(0, 0, 16);
    g.endFill();
    spr.setCenterRatio();
  }
}