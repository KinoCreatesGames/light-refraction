package ui;

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

  var health:h2d.Graphics;
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
    setupHealth();
    setupFlashLights();
  }

  public function setupHealth() {
    health = new h2d.Graphics(flow);
    health.beginFill(0xff0000, 1);
    health.drawCircle(0, 0, 3);
    health.endFill();
  }

  /**
   * Sets up the flash lights for rendering
   */
  public function setupFlashLights() {
    var flT = hxd.Res.img.flash_light.toAseprite().toTile();
    stdFlashLight = new TextureGauge(flT, flT, flow);
    stdFlashLight.flowType = UP_DOWN;
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
    health.clear();
    health.beginFill(0xff0000, 1);
    health.drawCircle(0, 0, 3);
    health.endFill();
  }

  public function renderFlashlights() {
    var pl = level.player;
    stdFlashLight.updatePerc(pl.flashLight.batteryLife);
  }

  public function resizeFlashLights() {
    stdFlashLight.x = 32;
    var scaledH = (h() / Const.UI_SCALE);
    stdFlashLight.y = Std.int(scaledH - (scaledH * .25));
    stdFlashLight.y = 270;
    // TODO - Play around with UI coordinates for best results.
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

  public function hide() {
    flow.visible = false;
    stdFlashLight.root.visible = false;
  }

  public function show() {
    flow.visible = true;
    stdFlashLight.root.visible = true;
  }
}