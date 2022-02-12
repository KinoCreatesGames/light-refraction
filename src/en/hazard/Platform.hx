package en.hazard;

import GameTypes.Lens;
import Utils.addToLayerBasedOnLens;
import h2d.col.Point;

class Platform extends Hazard implements LitEntity {
  public var isLit:Bool;
  public var test:h2d.Graphics;
  public var complete:Bool;
  public var point:Point;
  public var lens:Lens;

  public function new(pl:Entity_Platform) {
    super(pl.cx, pl.cy);
    lens = pl.f_RevealLens;
    setupGraphic();
    this.spr.alpha = 0;
    LitEntity.setupEntity(this, this);
    addToLayerBasedOnLens(this.spr, lens);
  }

  public function setupGraphic() {
    test = new h2d.Graphics(this.spr);
    test.beginFill(0x00ff00);
    test.drawRect(0, 0, 32, 32);
    test.endFill();
    test.y -= 32;
    test.x -= 16;
    // test.blendMode = Alpha;
    test.alpha = 1;
  }

  override function update() {
    super.update();
    this.handleLightInteraction();
  }

  public function handleLightInteraction() {
    LitEntity.handleLightInteraction(this, this, 2, Const.PLAT_FADE_TIME);
  }
}