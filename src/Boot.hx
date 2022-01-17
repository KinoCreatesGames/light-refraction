/**
  This class is the entry point for the app.
  It doesn't do much, except creating Main and taking care of app speed ()
**/

import h2d.filter.Nothing;
import hxd.Timer;
import shaders.CRTShader;
import shaders.CompositeShader;
import h3d.mat.TextureArray;
import h3d.Vector;
import h3d.pass.ScreenFx;
import shaders.SpotLightShader2D;
import h3d.Engine;
import renderer.CustomRenderer;
import dn.heaps.input.Controller;
import dn.heaps.input.ControllerAccess;
import h3d.mat.Texture;

class Boot extends hxd.App {
  public static var ME:Boot;

  public var renderer:CustomRenderer;
  public var spotlight:SpotLightShader2D;
  public var crt:CRTShader;

  /**
   * Shader that 
   * Combines  all the final textures together and render the scene.
   */
  public var composite:CompositeShader;

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
    // Apply pixel perfect rendering to scene
    s2d.filter = new Nothing();
    // s2d.scaleMode = ScaleMode.AutoZoom(320, 180, true);
    spotlight = new SpotLightShader2D();
    spotlight.texs = new TextureArray(engine.width, engine.height, 2, [Target]);
    spotlight.widthHeight = new Vector(engine.width, engine.height);
    spotlight.playerPos = new Vector(0, 0);
    composite = new CompositeShader(new TextureArray(engine.width,
      engine.height, 2, [Target]));
    composite.lightTexture = new Texture(engine.width, engine.height, [Target]);
    composite.hudTexture = new Texture(engine.width, engine.height, [Target]);
    crt = new CRTShader();
    crt.widthHeight = new Vector();
    crt.tex = new Texture(engine.width, engine.height, [Target]);
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
      // Unlit World
      composite.textures.clear(0, 1);
      composite.lightTexture.clear(0, 1);
      composite.lightTexture.resize(engine.width, engine.height);
      composite.hudTexture.clear(0, 1);
      composite.hudTexture.resize(engine.width, engine.height);
      spotlight.texs.clear(0, 1);
      engine.pushTarget(spotlight.texs, 0);
      engine.pushTarget(composite.textures, 1);

      // Populate the render texture for use in the shader
      // First Texture is just world without lights
      // Remove the lights from everything else in the level as well
      level.lights.members.iter((el) -> {
        el.turnOff();
      });
      if (!level.player.flashLightOff) {
        level.player.flashLight.turnOff();
      }
      level.hud.hide();
      s2d.render(e);
      engine.popTarget();

      engine.clear(0, 1);
      // Get copy of lit world
      s2d.render(e);
      engine.popTarget();
      engine.clear(0, 1);
      // Render spotlight info into same texture
      // level.root.drawTo(composite.lightTexture);
      if (!level.player.flashLightOff) {
        level.player.flashLight.turnOn();
        level.player.flashLight.lightG.drawTo(composite.lightTexture);
      }
      level.lights.members.iter((el) -> {
        el.turnOn();
        // el.hideGraphic();
        el.spr.drawTo(composite.lightTexture);
        // el.light.drawTo(composite.lightTexture);
      });

      // Update spotlight playerPos Information
      var absPos = level.player.spr.getAbsPos();
      spotlight.playerPos.x = (absPos.x);
      spotlight.playerPos.y = (absPos.y);
      spotlight.widthHeight.x = engine.width;
      spotlight.widthHeight.y = engine.height;
      ScreenFx.run(spotlight, composite.textures, 0);
      // Draw the HUD into the second texture
      // Note we can use the drawTo texture method to reduce render calls
      level.hud.show();
      level.hud.root.drawTo(composite.hudTexture);
      if (level.notif.isVisible()) {
        level.notif.root.drawTo(composite.hudTexture);
      }

      if (level.msg.isVisible()) {
        level.msg.root.drawTo(composite.hudTexture);
      }
      level.lights.members.iter((el) -> {
        el.showGraphic();
      });

      // ScreenFx.run(composite, crt.tex, 0); //Not needed?

      if (Game.ME.crtON) {
        crt.widthHeight.x = engine.width;
        crt.widthHeight.y = engine.height;
        crt.time += Timer.elapsedTime * 4;
        ScreenFx.run(composite, crt.tex, 0);
        new ScreenFx(crt).render();
      } else {
        new ScreenFx(composite).render();
      }
      // Compsite  Final Textures
    } else {
      // Render the standard scene in the game
      super.render(e);
    }
  }
}