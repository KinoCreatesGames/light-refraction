package en.collectibles;

/**
 * 
 * Restores the player health on pick up.
 */
class Health extends Collectible {
  public function new(heart:Entity_Health) {
    super(heart.cx, heart.cy);
  }

  override function setupGraphic() {
    super.setupGraphic();
    var g = new h2d.Graphics(this.spr);
    var tile = hxd.Res.img.HealthDrinkPNG.toTile();
    g.beginTileFill(0, 0, 1, 1, tile);
    g.drawTile(0, 0, tile);
    g.endFill();
    spr.setCenterRatio();
  }
}