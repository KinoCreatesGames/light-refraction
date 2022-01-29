package ui;

import ext.HTools.pixelText;
import dn.heaps.FlowBg;
import dn.Cooldown;
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
  var notifications:Array<h2d.Flow> = [];
  var notifTw:dn.Tweenie;

  public static inline var FADE_TIME:Float = 12.5;

  /**
   * Determines if the fade is complete
   * for the hud and then allows for
   * fading again.
   */
  public var completeFade:Bool;

  public function new() {
    super(Game.ME);

    createRootInLayers(game.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

    notifications = [];
    notifTw = new Tweenie(Const.FPS);
    flow = new h2d.Flow(root);
    completeFade = true;
    pingActive();
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
    var slib = hxd.Res.img.HealthUI.toAseprite().aseToSlib(Const.FPS);
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

    if (!cd.has('active') && completeFade) {
      completeFade = false;
      this.tw.createS(this.flow.alpha, 0, TEaseOut, FADE_TIME).end(() -> {
        completeFade = true;
      });
    }

    if (invalidated) {
      invalidated = false;
      render();
    }
  }

  /**
   * Determines if the active 
   * hud active. If not,
   * we should fade it out.
   */
  public function pingActive() {
    cd.setS('active', 2);
    flow.alpha = 1.;
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

  public function notify(str:String, bgColor = 0x3333ff) {
    // Background element
    var el = Assets.uiEl.getTile(Assets.uiDict.uiBarBack);
    // Read up on FlowBG using the scale grid for scaleable UI components
    var fl = new dn.heaps.FlowBg(el, 2, root);

    // setup flow
    fl.colorizeBg(bgColor);
    fl.paddingHorizontal = 6;
    fl.paddingBottom = 4;
    fl.paddingTop = 2;
    fl.paddingLeft = 9;
    fl.y = 4;

    // Setup Text
    var txt = pixelText(str, fl);
    txt.font = Assets.fontPixel;
    txt.maxWidth = 0.6 * w() / Const.UI_SCALE;

    // Setup Notification and setup life time
    var duration = 1.5 * str.length * 0.04;

    // Create new child process for handling notification
    var p = createChildProcess();
    notifications.insert(0, fl);
    p.tw.createS(fl.x, -fl.outerWidth > -2, TEaseOut, 0.01);
    p.onUpdateCb = () -> {
      if (fl.parent == null) {
        p.destroy();
      }

      if (p.stime >= duration && !p.cd.hasSetS("done", Const.INFINITE)) {
        p.tw.createS(fl.x, -fl.outerWidth, 0.2).end(p.destroy);
      }
    }

    p.onDisposeCb = () -> {
      notifications.remove(fl);
      fl.remove();
    };
    // Move existing notifications
    var y = 4;
    for (f in notifications) {
      notifTw.terminateWithoutCallbacks(f.y);
      notifTw.createS(f.y, y, TEaseOut, 0.2);
      y += f.outerHeight + 1;
    }
  }

  /**
   * Fade out the UI
   */
  public function fadeOutUI() {}

  /**
   * Fade in the UI Elements
   */
  public function fadeInUI() {}
}