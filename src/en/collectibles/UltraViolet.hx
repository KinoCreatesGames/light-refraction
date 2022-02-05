package en.collectibles;

import ext.HTools.createGraphics;

/**
 * UltraViolet flashlight lens
 * that updates the characters
 * and sets the unlocked version of the upgrade
 * to true.
 */
class UltraViolet extends Collectible {
  public function new(uv:Entity_UltraViolet) {
    super(uv.cx, uv.cy);
  }

  override function setupGraphic() {
    super.setupGraphic();
    var g = createGraphics(this.spr);
    g.beginFill(0xff00ff);
    g.drawCircle(cx, cy, Const.GRID);
    g.endFill();
    spr.setCenterRatio();
  }
}