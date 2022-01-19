package en.objects;

import shaders.PointLightFilter;
import dn.heaps.filter.PixelOutline;
import h3d.prim.Disc;
import h3d.Vector;
import shaders.SineDeformShader2D;
import h2d.Bitmap;
import shaders.PointLightShader2D;
import hxd.Timer;

class Lamp extends Light {
  var lightRadius:Float;
  var lightColor:Int;

  public function new(lamp:Entity_Lamp) {
    super(lamp.cx, lamp.cy);
    lightRadius = lamp.f_Radius;
    lightColor = lamp.f_LightColor_int;
    isOn = lamp.f_isOn;
    setupLight();
    setupGraphic();
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
    var shader = new PointLightShader2D();
    shader.widthHeight.x = game.w();
    shader.widthHeight.y = game.h();
    shader.pos.x = this.spr.x;
    shader.pos.y = this.spr.y;
    shader.color = Vector.fromColor(0x111111);
    var d = Disc.defaultUnitDisc();
    var colorTile = h2d.Tile.fromColor(lightColor, 1, 1);
    light.beginTileFill(0, 0, 64, 64, colorTile);
    for (point in d.points) {
      point.scale(5);
      light.addVertex(point.x, point.y, 1, 1, 1, 1, 0.5, .5);
    }
    // light.drawCircle(0, 0, lightRadius);
    light.endFill();
    light.addShader(shader);
    light.colorAdd = Vector.fromColor(lightColor);
    // light.alpha = .3; alpha doesn't work once shader is applied

    // light.filter = new PixelOutline(0x0000ff);
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
    light.visible = isOn;
  }

  override function turnOn() {
    isOn = true;
    light.visible = isOn;
  }

  override function hideGraphic() {
    super.hideGraphic();
  }

  override function showGraphic() {
    super.showGraphic();
  }
}