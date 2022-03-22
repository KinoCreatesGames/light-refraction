package en.hazard;

import h2d.col.Point;
import GameTypes.Lens;
import Utils.addToLayerBasedOnLens;

/**
 * Block within the game used for pushing around
 * via a light source within the game.
 */
class Block extends Hazard implements LitEntity {
  public static inline var MOVE_SPD:Float = .1;

  public var point:Point;
  public var lens:Lens;
  public var complete:Bool;
  public var isLit:Bool;

  public function new(bl:Entity_Block) {
    super(bl.cx, bl.cy);
    LitEntity.setupEntity(this, this);
    addToLayerBasedOnLens(this.spr, lens);
  }

  override function update() {
    super.update();
    handleLightInteraction();
  }

  public function setupGraphic() {
    var g = this.spr.createGraphics();
    var size = 32;
    g.beginFill(0xffaaff);
    g.drawRect(0, 0, size, size);
    g.y -= 32;
    g.x -= 16;
  }

  public function handleLightInteraction() {
    // setup the point
    this.point.x = this.spr.x;
    this.point.y = this.spr.y;

    if (level.player != null && level.player.lightCollider != null) {
      var inCone = level.player.lightCollider.contains(this.point);
      if (inCone) {
        this.isLit = true;
        handleLightMove();
      } else {
        this.isLit = false;
      }
    }
  }

  public function handleLightMove() {
    var pl = level.player;
    var pt = new Point(pl.spr.x, pl.spr.y).toVec();
    var ptTwo = point.toVec();
    var result = ptTwo.sub(pt);
    result.normalize();

    var dirX = M.round(result.x);
    var dirY = M.round(result.y);

    dx = dirX * MOVE_SPD;
    dy = dirY * MOVE_SPD;
  }
}