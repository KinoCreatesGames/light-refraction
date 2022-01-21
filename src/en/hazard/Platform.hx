package en.hazard;

import h2d.col.Point;

class Platform extends Hazard {
  public var isLit:Bool;
  public var test:h2d.Graphics;
  public var complete:Bool;
  public var point:Point;

  public function new(pl:Entity_Platform) {
    super(pl.cx, pl.cy);
    isLit = false;
    this.spr.alpha = 0;
    this.complete = true;
    this.point = new Point(this.spr.x, this.spr.y);
    setupGraphic();
  }

  public function setupGraphic() {
    test = new h2d.Graphics(this.spr);
    test.beginFill(0x00ff00);
    test.drawRect(0, 0, 32, 32);
    test.endFill();
    // test.blendMode = Alpha;
    test.alpha = 1;
  }

  override function update() {
    super.update();
    this.point.x = this.spr.x;
    this.point.y = this.spr.y;
    if (!cd.has('lightTransition')) {
      var inCone = level.player.lightCollider.contains(this.point);
      if (!isLit && inCone && level.player.flashLight.isOn()) {
        isLit = true;
        complete = false;
        level.tw.createS(this.spr.alpha, 1, TEase, 2).end(() -> {
          complete = true;
        });
        cd.setS('lightTransition', 2);
      } else if (isLit && !inCone) {
        isLit = false;
        complete = false;
        level.tw.createS(this.spr.alpha, 0, TEase, 2).end(() -> {
          complete = true;
        });
        cd.setS('lightTransition', 2);
      }
    }
  }
}