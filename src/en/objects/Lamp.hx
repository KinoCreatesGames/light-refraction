package en.objects;

import hxd.Timer;

class Lamp extends Light {
  var lightRadius:Float;
  var lightColor:Int;

  public function new(lamp:Entity_Lamp) {
    super(lamp.cx, lamp.cy);
    lightRadius = lamp.f_Radius;
    lightColor = lamp.f_LightColor_int;
    isOn = lamp.f_isOn;
    setupGraphic();
    setupLight();
  }

  public function setupGraphic() {
    var g = new h2d.Graphics(this.spr);
    var tile = hxd.Res.img.Lamp.toTile();
    g.beginTileFill(0, 0, 1, 1, tile);
    g.drawTile(0, 0, tile);
    g.endFill();
    graphic = g;
    g.x -= 16;
    g.y -= 16;
  }

  public function setupLight() {
    light = new h2d.Graphics(this.spr);
    // Create Light Circle
    light.blendMode = Add;
    // light.alpha = 0.7;

    light.beginFill(lightColor);
    light.drawCircle(0, 0, lightRadius);
    light.endFill();
  }

  override function update() {
    super.update();
    var factor = M.fclamp(M.fabs(Math.sin(Timer.frameCount.toRad() * .85)) * 1.25,
      1, 1.25);
    light.setScale(factor);
    // Additional Code for shading lights separately from the rest of the environment
    light.visible = isOn;
  }

  override function turnOff() {
    isOn = false;
  }

  override function turnOn() {
    isOn = true;
  }

  override function hideGraphic() {
    super.hideGraphic();
  }

  override function showGraphic() {
    super.showGraphic();
  }
}