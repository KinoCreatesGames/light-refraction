package ui;

import en.Player;
import dn.heaps.assets.Aseprite;
import h2d.Anim;
import haxe.rtti.CType.Rights;
import dn.Process;

class Hud extends dn.Process {
  public var game(get, never):Game;

  inline function get_game()
    return Game.ME;

  public var fx(get, never):Fx;

  inline function get_fx()
    return Game.ME.fx;

  public var level(get, never):Level;

  inline function get_level()
    return Game.ME.level;

  var flow:h2d.Flow;
  var invalidated = true;

  var healthGauge:HSprite;
  var stdFlashLight:TextureGauge;
  var spiritFlashLight:TextureGauge;

  public function new() {
    super(Game.ME);

    createRootInLayers(game.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

    flow = new h2d.Flow(root);
    setup();
    Process.resizeAll();
  }

  public function setup() {
    flow.layout = Horizontal;
    flow.horizontalSpacing = 12;
    flow.horizontalAlign = Left;
    flow.verticalAlign = Middle;
  }

  public function setupHealth(player:Player) {
    // Might have to update this with the tmod while game is running to match studio
    var slib = Aseprite.convertToSLib(Const.FPS,
      hxd.Res.img.HealthUI.toAseprite());
    var spr = new HSprite(slib);
    spr.anim.registerStateAnim('goodHealth', 1, 1,
      () -> player.healthPerc > .75);
    spr.anim.registerStateAnim('dangerHealth', 1, 1.2,
      () -> player.healthPerc < .75 && player.healthPerc > .4);
    spr.anim.registerStateAnim('badHealth', 1, 1.5,
      () -> player.healthPerc <= .4);
    // Create Health Gauge
    // var front = new Anim();
    healthGauge = spr;
    flow.addChild(healthGauge);
  }

  /**
   * Sets up the flash lights for rendering
   */
  public function setupFlashLights() {
    var front = Assets.uiEl.getTile(Assets.uiDict.BatteryFrontFull);
    var back = Assets.uiEl.getTile(Assets.uiDict.BatteryBG);
    stdFlashLight = new TextureGauge(front, back, flow);
    stdFlashLight.flowType = RIGHT_LEFT;
  }

  override function onResize() {
    super.onResize();
    root.setScale(Const.UI_SCALE);
    if (level != null) {
      resizeFlashLights();
    }
  }

  public inline function invalidate()
    invalidated = true;

  function render() {
    if (level != null) {
      renderHealth();
      renderFlashlights();
    }
  }

  public function renderHealth() {
    var pl = level.player;
  }

  public function renderFlashlights() {
    var pl = level.player;
    stdFlashLight.updatePerc(pl.flashLight.batteryLife);
  }

  public function resizeFlashLights() {
    // stdFlashLight.x = 32;
    var scaledH = (h() / Const.UI_SCALE);
    // stdFlashLight.y = Std.int(scaledH - (scaledH * .25));
    // stdFlashLight.y = 270;
    // TODO - Play around with UI coordinates for best results. Look at pixel perfect rendering
    // trace(Const.UI_SCALE);
    // trace(h());
    // trace(stdFlashLight.y);
  }

  override function postUpdate() {
    super.postUpdate();

    if (invalidated) {
      invalidated = false;
      render();
    }
  }

  public function isVisible() {
    return flow.visible;
  }

  public function hide() {
    flow.visible = false;
    if (stdFlashLight != null) {
      stdFlashLight.root.visible = false;
    }
  }

  public function show() {
    flow.visible = true;
    if (stdFlashLight != null) {
      stdFlashLight.root.visible = true;
    }
  }
}