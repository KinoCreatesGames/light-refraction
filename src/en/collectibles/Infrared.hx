package en.collectibles;

import ext.HTools.createGraphics;

/**
 * Infrared flashlight lens that updates
 * the character and sets the unlocked
 * version of the upgrade to true.
 */
class Infrared extends Collectible {
  public function new(ir:Entity_Infrared) {
    super(ir.cx, ir.cy);
  }

  override function setupGraphic() {
    super.setupGraphic();
    var g = createGraphics(this.spr);
    g.beginFill(0xff0000);
    g.drawCircle(cx, cy, Const.GRID);
    g.endFill();
    spr.setCenterRatio();
  }
}