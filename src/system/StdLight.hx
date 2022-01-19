package system;

import hxd.Timer;
import h3d.Vector;
import shaders.PointLightShader2D;
import h2d.Drawable;

class StdLight extends Drawable {
  public var game(get, null):Game;

  public inline function get_game():Game {
    return Game.ME;
  }

  var lightRadius:Float;
  var lightColor:Int;

  public var isOn:Bool;
  public var light:h2d.Graphics;

  public function new(parent, light:Entity_StdLight) {
    super(parent);
    lightRadius = light.f_Radius;
    lightColor = light.f_LightColor_int;
    isOn = light.f_isOn;
    this.x = light.pixelX;
    this.y = light.pixelY;
    setupLight();
  }

  public function setupLight() {
    light = new h2d.Graphics(this);

    // Create Light Circle
    light.blendMode = SoftAdd;
    // light.alpha = 0.7;
    var shader = new PointLightShader2D();
    shader.widthHeight.x = game.w();
    shader.widthHeight.y = game.h();
    shader.pos.x = this.x;
    shader.pos.y = this.y;
    shader.color = Vector.fromColor(0x111111);
    var colorTile = h2d.Tile.fromColor(lightColor, 1, 1);
    light.beginTileFill(0, 0, 64, 64, colorTile);

    light.drawCircle(0, 0, lightRadius);
    light.endFill();
    light.addShader(shader);
    // light.colorAdd = Vector.fromColor(lightColor);
  }

  public function update() {
    var factor = M.fclamp(M.fabs(Math.sin(Timer.frameCount.toRad() * .85)) * 1.25,
      1, 1.25);
    light.setScale(factor);
    // Additional Code for shading lights separately from the rest of the environment
    light.visible = isOn;
  }

  public function turnOff() {
    isOn = false;
    light.visible = isOn;
  }

  public function turnOn() {
    isOn = true;
    light.visible = isOn;
  }

  public function hideGraphic() {
    light.visible = false;
  }

  public function showGraphic() {
    light.visible = true;
  }
}