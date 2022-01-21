package en.hazard;

import h2d.col.Point;

class MovingPlatform extends Hazard {
  public var path:Array<Point>;
  public var looping:Bool;

  public function new(mp:Entity_MovingPlatform) {
    super(mp.cx, mp.cy);
    looping = mp.f_loop;
    path = mp.f_Path.map((p) -> p.LDPtoPoint());
  }

  override function update() {
    super.update();
    updatePath();
  }

  public function updatePath() {}
}