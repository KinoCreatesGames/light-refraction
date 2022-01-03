package en.objects;

import hxd.Timer;

class Lamp extends Entity {
  var light:h2d.Graphics;
  var lightRadius:Float;
  var lightColor:Int;

  public function new(lamp:Entity_Lamp) {
    super(lamp.cx, lamp.cy);
    lightRadius = lamp.f_Radius;
    lightColor = lamp.f_LightColor_int;
    setupLight();
  }

  public function setupLight() {
    light = new h2d.Graphics(this.spr);
    // Create Light Circle
    light.blendMode = Add;
    // light.alpha = 0.5;
    light.beginFill(lightColor);
    light.drawCircle(cx, cy, lightRadius);
    light.endFill();
  }

  override function update() {
    super.update();
    var factor = M.fclamp(M.fabs(Math.sin(Timer.frameCount.toRad() * .85)) * 1.25,
      1, 1.25);
    light.setScale(factor);
  }
}