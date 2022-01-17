package ui.cmp;

import h2d.Bitmap;
import h2d.Mask;
import h2d.Drawable;

enum abstract Flow(String) from String to String {
  var LEFT_RIGHT:String = 'LeftRight';
  var RIGHT_LEFT:String = 'RightLeft';
  var UP_DOWN:String = 'UpDown';
  var DOWN_UP:String = 'DownUp';
}

/**
 * Simple gauge using a mask
 * and drawable components
 * that can be used to represent a guage
 * on the scren.
 */
class Gauge {
  public var root:h2d.Object;
  public var front:h2d.Graphics;
  public var back:h2d.Graphics;
  public var flowType:Flow;
  public var mask:Mask;

  public var invalidated:Bool = false;

  /**
   * The percentage of the gauge.
   * Determiens the amount of gauge to show.
   */
  public var delta:Float = 1;

  public var x(get, set):Int;
  public var y(get, set):Int;

  public function get_x() {
    return Std.int(this.root.x);
  }

  public function set_x(value:Int) {
    this.root.x = value;
    return Std.int(this.root.x);
  }

  public function get_y() {
    return Std.int(this.root.y);
  }

  public function set_y(value:Int) {
    this.root.y = value;
    return Std.int(this.root.y);
  }

  // TODO: extract this out  and just pass width, height, and
  // also add in the color front / back
  public function new(front:h2d.Graphics, back:h2d.Graphics,
      parent:h2d.Object) {
    this.flowType = RIGHT_LEFT;
    root = new h2d.Object(parent);
    this.back = back;
    this.front = front;
    root.addChild(back);
    root.addChild(front);
    // TODO figure out masking coordinates
    this.mask.x = this.front.x;
    this.mask.y = this.front.y;
  }

  public function updatePerc(amount:Float) {}

  public inline function invalidate() {
    invalidated = true;
    update();
  }

  public function update() {
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