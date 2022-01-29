package ui.cmp;

/**
 * Graphic button class for convience
 * when creating UI elements within the game. 
 * Onclick is not set by default. 
 * Access it via Btn.onClick = ;
 */
class GBtn extends BaseBtn {
  public var g:h2d.Graphics;
  public var tile:h2d.Tile;

  public function new(tile:h2d.Tile, color:Int = 0xffffff,
      ?parent:h2d.Object) {
    super(parent);
    this.tile = tile;
    g = new h2d.Graphics(parent);
    g.beginTileFill(this.tile);
    g.drawTile(0, 0, this.tile);
    g.endFill();
    int.width = tile.width;
    int.height = tile.height;
    setupEvents();
  }

  public inline function setupEvents() {
    int.onOut = (event) -> {
      g.alpha = 1;
    }

    int.onOver = (event) -> {
      g.alpha = 0.5;
    }
  }
}