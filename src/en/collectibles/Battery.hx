package en.collectibles;

/**
 * Battery that allows you to recharge your flashlight
 * within the game, preventing the light from going out.
 */
class Battery extends Collectible {
  public function new(bt:Entity_Battery) {
    super(bt.cx, bt.cy);
  }

  override function setupGraphic() {
    super.setupGraphic();
    var g = new h2d.Graphics(this.spr);
    var tile = hxd.Res.img.BatterySmallPNG.toTile();
    g.beginTileFill(0, 0, 1, 1, tile);
    g.drawTile(0, 0, tile);
    g.endFill();
    spr.setCenterRatio();
  }
}