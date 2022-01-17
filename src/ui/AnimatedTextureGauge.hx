package ui;

import h2d.Tile;
import h2d.Anim;

class AnimatedTextureGauge extends TextureGauge {
  public var frontAnim:HSprite;

  public function new(front:HSprite, back:Tile, parent) {
    frontAnim = front;
    frontAnim.tile;
    super(frontAnim.tile, back, parent);
    this.mask.addChild(frontAnim);
  }

  override function update() {
    // Replace current tile with the updated tile
    // this.front.tile = frontAnim.frameData.tile;
    switch (flowType) {
      case LEFT_RIGHT:
        this.front.scaleX = -delta;
      case RIGHT_LEFT:
        var result = Std.int(this.front.tile.width * delta);
        this.mask.width = result;
      case DOWN_UP:
        this.mask.height = Std.int(this.front.tile.height * delta);
      case UP_DOWN:
        var result = Std.int(this.front.tile.height * delta);
        var offset = this.front.tile.height - result;
        this.mask.height = result;
        this.mask.y = offset;
        this.front.y = -offset;
    }
    invalidated = false;
  }
}