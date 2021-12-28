import scn.GameOver;
import scn.Pause;
import en.Enemy;
import en.collectibles.Collectible;
import en.Player;

class Level extends dn.Process {
  var game(get, never):Game;

  inline function get_game()
    return Game.ME;

  var fx(get, never):Fx;

  inline function get_fx()
    return Game.ME.fx;

  /** Level grid-based width**/
  public var cWid(get, never):Int;

  inline function get_cWid()
    return 16;

  /** Level grid-based height **/
  public var cHei(get, never):Int;

  inline function get_cHei()
    return 16;

  /** Level pixel width**/
  public var pxWid(get, never):Int;

  inline function get_pxWid()
    return cWid * Const.GRID;

  /** Level pixel height**/
  public var pxHei(get, never):Int;

  inline function get_pxHei()
    return cHei * Const.GRID;

  var invalidated = true;

  // Game varibales
  public var player:Player;

  public var collectibles:Group<Collectible>;
  public var enemies:Group<Enemy>;

  public function new() {
    super(Game.ME);
    createRootInLayers(Game.ME.scroller, Const.DP_BG);
    setup();
  }

  public function setup() {
    setupGroups();
    setupEntities();
  }

  public function setupGroups() {
    collectibles = new Group<Collectible>();
    enemies = new Group<Enemy>();
  }

  public function setupEntities() {
    player = new Player(8, 8);
    var e = new Enemy(3, 3);
  }

  /** TRUE if given coords are in level bounds **/
  public inline function isValid(cx, cy)
    return cx >= 0 && cx < cWid && cy >= 0 && cy < cHei;

  /** Gets the integer ID of a given level grid coord **/
  public inline function coordId(cx, cy)
    return cx + cy * cWid;

  /** Ask for a level render that will only happen at the end of the current frame. **/
  public inline function invalidate() {
    invalidated = true;
  }

  // Collision detection

  public function collidedEnemy(x:Int, y:Int) {
    return enemies.members.filter((enemy) -> enemy.cx == x && enemy.cy == y
      && enemy.isAlive())
      .first();
  }

  public function collidedCollectible(x:Int, y:Int) {
    return collectibles.members.filter((collectible) -> collectible.cx == x
      && collectible.cy == y && collectible.isAlive())
      .first();
  }

  override function update() {
    super.update();
    handlePause();
  }

  /**
   * Handles pausing the game
   */
  public function handlePause() {
    if (game.ca.isKeyboardPressed(K.ESCAPE)) {
      hxd.Res.sound.pause_in.play();
      this.pause();
      new Pause();
    }
  }

  public function handleGameOver() {
    if (player.isDead()) {
      this.pause();
      new GameOver();
    }
  }

  function render() {
    // Placeholder level render
    root.removeChildren();
    for (cx in 0...cWid)
      for (cy in 0...cHei) {
        var g = new h2d.Graphics(root);
        if (cx == 0
          || cy == 0
          || cx == cWid - 1
          || cy == cHei - 1) g.beginFill(0xffcc00); else
          g.beginFill(Color.randomColor(rnd(0, 1), 0.5, 0.4));
        g.drawRect(cx * Const.GRID, cy * Const.GRID, Const.GRID, Const.GRID);
      }
  }

  override function postUpdate() {
    super.postUpdate();

    if (invalidated) {
      invalidated = false;
      render();
    }
  }

  /**
   * Disposes of all elements within the level
   * including the player, bgm, collectibles, enemies, and more.
   */
  override function onDispose() {
    // Destruction of the level elements in the game
    for (collectible in collectibles) {
      collectible.destroy();
    }

    for (enemy in enemies) {
      enemy.destroy();
    }

    player.destroy();
    collectibles = null;
    enemies = null;
    super.onDispose();
  }
}