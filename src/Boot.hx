/**
  This class is the entry point for the app.
  It doesn't do much, except creating Main and taking care of app speed ()
**/

import h3d.mat.TextureArray;
import h3d.Vector;
import h3d.pass.ScreenFx;
import shaders.SpotLightShader2D;
import h3d.Engine;
import renderer.CustomRenderer;
import dn.heaps.Controller;
import dn.heaps.Controller.ControllerAccess;
import h3d.mat.Texture;

class Boot extends hxd.App {
  public static var ME:Boot;

  public var renderer:CustomRenderer;
  public var spotlight:SpotLightShader2D;

  #if debug
  var tmodSpeedMul = 1.0;
  var ca(get, never):ControllerAccess;

  inline function get_ca()
    return Main.ME.ca;
  #end

  /**
    App entry point
  **/
  static function main() {
    new Boot();
  }

  /**
    Called when engine is ready, actual app can start
  **/
  override function init() {
    ME = this;
    renderer = new CustomRenderer();
    s3d.renderer = renderer;
    new Main(s2d);
    spotlight = new SpotLightShader2D();
    spotlight.texs = new TextureArray(engine.width, engine.height, 2, [Target]);
    spotlight.widthHeight = new Vector(engine.width, engine.height);
    spotlight.playerPos = new Vector(0, 0);
    onResize();
  }

  override function onResize() {
    super.onResize();
    dn.Process.resizeAll();
  }

  /** Main app loop **/
  override function update(deltaTime:Float) {
    super.update(deltaTime);

    // Controller update
    Controller.beforeUpdate();

    var currentTmod = hxd.Timer.tmod;
    #if debug
    if (Main.ME != null && !Main.ME.destroyed) {
      // Slow down app (toggled with a key)
      if (ca.isKeyboardPressed(K.NUMPAD_SUB)
        || ca.isKeyboardPressed(K.HOME) || ca.dpadDownPressed())
        tmodSpeedMul = tmodSpeedMul >= 1 ? 0.2 : 1;
      currentTmod *= tmodSpeedMul;

      // Turbo (by holding a key)
      currentTmod *= ca.isKeyboardDown(K.NUMPAD_ADD)
        || ca.isKeyboardDown(K.END) || ca.ltDown() ? 5 : 1;
    }
    #end

    // Update all dn.Process instances
    dn.Process.updateAll(currentTmod);
  }

  @:access(h3d.scene.Scene, h3d.scene.Renderer, CustomRenderer)
  override function render(e:Engine) {
    // If we're on the level we're going to take the
    // render texture and use it for the vignette effect
    // For the spotlight for the player character
    if (Game.ME != null && Game.ME.level != null && !Game.ME.level.destroyed) {
      var level = Game.ME.level;
      engine.pushTarget(spotlight.texs, 0);
      engine.pushTarget(spotlight.texs, 1);
      engine.clear(0, 1);

      // Populate the render texture for use in the shader
      // First Texture is just world without lights
      // Remove the lights from everything else in the level as well
      level.lights.members.iter((el) -> {
        el.spr.visible = false;
      });
      level.player.flashLight.turnOff();
      s2d.render(e);
      engine.popTarget();

      // Light Texture
      engine.clear(0, 1);
      level.player.flashLight.turnOn();
      level.lights.members.iter((el) -> {
        el.spr.visible = true;
      });
      s2d.render(e);
      engine.popTarget();

      // Update spotlight playerPos Information
      var absPos = level.player.spr.getAbsPos();
      spotlight.playerPos.x = (absPos.x);
      spotlight.playerPos.y = (absPos.y);
      spotlight.widthHeight.x = engine.width;
      spotlight.widthHeight.y = engine.height;
      spotlight.flashlightTint = level.player.flashLight.vColor;
      new ScreenFx(spotlight).render();
    } else {
      // Render the standard scene in the game
      super.render(e);
    }
  }
}