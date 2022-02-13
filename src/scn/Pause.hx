package scn;

import ext.GameTools.createEntry;
import ui.GhostJournal;
import hxd.snd.Channel;
import ui.cmp.TxtBtn;
import dn.legacy.Controller.ControllerAccess;

class Pause extends dn.Process {
  var ct:ControllerAccess;
  var mask:h2d.Bitmap;

  public var se:Channel;

  var padding:Int;

  public var win:h2d.Flow;

  var commandFlow:h2d.Flow;
  var uiJournal:GhostJournal;
  var sysFlow:h2d.Flow;
  var renderArea:h2d.Flow;

  public var titleText:h2d.Text;
  public var elapsed:Float;

  public function new() {
    super(Game.ME);
    ct = Main.ME.controller.createAccess('pause');
    ct.takeExclusivity();
    createRootInLayers(Game.ME.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix();
    mask = new h2d.Bitmap(h2d.Tile.fromColor(0x0, 1, 1, 0.6), root);
    root.under(mask);
    elapsed = 0;
    setupPause();
    dn.Process.resizeAll();
  }

  public function setupPause() {
    win = new h2d.Flow(root);
    win.borderHeight = 7;
    win.borderWidth = 7;
    win.minWidth = Std.int(w() * 0.5);
    win.verticalSpacing = 16;
    win.layout = Vertical;
    win.horizontalAlign = Middle;
    var title = new h2d.Text(Assets.fontLarge, win);
    title.text = Lang.t._('Pause');
    title.center();
    titleText = title;
    createCommand(win);
    createRenderArea(win);
    createGhostJournal(renderArea);
    addOptions(win);
  }

  public function createCommand(win:h2d.Flow) {
    commandFlow = new h2d.Flow(win);
    commandFlow.layout = Horizontal;
    commandFlow.horizontalSpacing = 16;
    commandFlow.horizontalAlign = Left;

    // Create Buttons
    var journal = new TxtBtn(Lang.t._('Journal'), commandFlow);
    journal.onClick = (event) -> {
      goToJournal();
    }

    var sysm = new TxtBtn(Lang.t._('System'), commandFlow);
    sysm.onClick = (event) -> {
      gotoSystem();
    };
  }

  public function goToJournal() {
    // Set the Journal stuff directly into the render area
    renderArea.removeChildren();
    renderArea.addChild(uiJournal);
  }

  public function gotoSystem() {
    renderArea.removeChildren();
    renderArea.addChild(sysFlow);
  }

  public function createRenderArea(win:h2d.Flow) {
    renderArea = new h2d.Flow(win);
    renderArea.verticalAlign = Top;
    renderArea.minWidth = 300;
    renderArea.minHeight = 300;
    win.padding = 12;
  }

  public function createGhostJournal(win:h2d.Flow) {
    uiJournal = new GhostJournal(win, {
      current: null,
      entries: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((x) -> createEntry())
    });
  }

  public function addOptions(win:h2d.Flow) {
    // Title Text
    sysFlow = new h2d.Flow();
    sysFlow.layout = Vertical;
    sysFlow.horizontalAlign = Middle;
    sysFlow.verticalAlign = Top;
    sysFlow.verticalSpacing = 16;
    // sysFlow.minWidth = Std.int(w() * .5);
    sysFlow.borderHeight = 7;
    sysFlow.borderWidth = 7;

    // Add Buttons
    var resume = new TxtBtn(Lang.t._('Resume'), sysFlow);
    resume.center();
    resume.onClick = (event) -> {
      resumeGame();
    }

    // var restart = new TxtBtn(win.outerWidth, Lang.t._('Restart'), win);
    // restart.center();
    // restart.onClick = (event) -> {
    //   restartLevel();
    // }

    var quit = new TxtBtn(Lang.t._('To Title'), sysFlow);
    quit.center();
    quit.onClick = (event) -> {
      toTitle();
    }
  }

  public function resumeGame() {
    ct.releaseExclusivity();
    Game.ME.level.resume();
    se = Assets.pauseOut.play();
    Game.ME.level.scnPause = null;
    this.destroy();
  }

  public function restartLevel() {
    ct.releaseExclusivity();
    Game.ME.level.resume();
    // Game.ME.reloadCurrentLevel();
    this.destroy();
  }

  public function toTitle() {
    ct.releaseExclusivity();
    Game.ME.level.resume();
    Game.ME.level.scnPause = null;
    Game.ME.level.destroy();
    se = Assets.pauseOut.play();
    this.destroy();
    new Title();
  }

  override function update() {
    super.update();
    elapsed = (uftime % 180) * (Math.PI / 180);
    titleText.alpha = M.fclamp(Math.sin(elapsed) + 0.3, 0.3, 1);

    // Escape Leave Method
    if (ct.isKeyboardPressed(K.ESCAPE)) {
      // Return to the previous scene without creating any
      // new instances
      // Play Leave
      resumeGame();
    }
  }

  override function onResize() {
    super.onResize();
    // Resize all elements to be centered on screen

    if (mask != null) {
      var w = M.ceil(w());
      var h = M.ceil(h());
      mask.scaleX = w;
      mask.scaleY = h;
    }
    // win.x = (w() * 0.5 - (win.outerWidth * 0.0));
    win.y = (h() * 0.5 - (win.outerHeight * 0.5));
    win.x = 0;
    // win.y =
  }

  override function onDispose() {
    super.onDispose();
    se = null;
  }
}