import en.collectibles.Health;
import h2d.col.Bounds;
import en.hazard.Exit;
import en.hazard.Hazard;
import en.objects.Lamp;
import en.BaseEnt;
import h2d.col.Point;
import ui.Hud;
import en.collectibles.Battery;
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
    return 32;

  /** Level grid-based height **/
  public var cHei(get, never):Int;

  inline function get_cHei()
    return 32;

  /** Level pixel width**/
  public var pxWid(get, never):Int;

  inline function get_pxWid()
    return cWid * Const.GRID;

  /** Level pixel height**/
  public var pxHei(get, never):Int;

  public var hud(get, never):Hud;

  public function get_hud() {
    return Game.ME.hud;
  }

  inline function get_pxHei()
    return cHei * Const.GRID;

  var invalidated = true;

  // Game varibales
  public var player:Player;

  public var collectibles:Group<Collectible>;
  public var enemies:Group<Enemy>;
  public var lights:Group<Entity>;
  public var hazards:Group<Hazard>;
  public var data:LDTkProj_Level;

  public function new(?levelData:LDTkProj_Level) {
    super(Game.ME);
    createRootInLayers(Game.ME.scroller, Const.DP_BG);
    if (levelData != null) {
      data = levelData;
      setup();
    }
    hud.show();
  }

  public function setup() {
    setupGroups();
    setupEntities();
  }

  public function setupGroups() {
    collectibles = new Group<Collectible>();
    enemies = new Group<Enemy>();
    lights = new Group<Entity>();
    hazards = new Group<Hazard>();
  }

  public function setupEntities() {
    for (pl in data.l_Entities.all_Player) {
      player = new Player(pl.cx, pl.cy);
    }
    setupEnemies();
    setupCollectibles();
    setupLights();
    setupHazards();
  }

  public function setupEnemies() {
    for (enemy in data.l_Entities.all_Enemy) {
      var e = new Enemy(enemy.cx, enemy.cy);
      enemies.add(e);
    }
  }

  public function setupCollectibles() {
    // Batteries
    for (battery in data.l_Entities.all_Battery) {
      var bt = new Battery(battery);
      collectibles.add(bt);
    }

    // Hearts
    for (health in data.l_Entities.all_Health) {
      var healthDrink = new Health(health);
      collectibles.add(healthDrink);
    }
  }

  public function setupLights() {
    for (lg in data.l_Entities.all_Lamp) {
      var light = new Lamp(lg);
      lights.add(light);
    }
  }

  /**
   * Sets up the hazards within the game.
   * Allowing you to interact with them.
   */
  public function setupHazards() {
    for (enExit in data.l_Entities.all_Exit) {
      var exit = new Exit(enExit);
      hazards.add(exit);
    }
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

  public function collideWithLightEn(entity:BaseEnt) {
    if (entity != null && entity.isAlive() && entity.ready) {
      var absPos = entity.spr.getAbsPos();
      var p = new Point(absPos.x, absPos.y);
      // trace('Destroy, ${absPos.x}, ${absPos.y}');
      return player.lightCollider.contains(p) && !player.flashLightOff;
    }
    return false;
  }

  /**
   * Collision detection between the elements on the level.  
   * Level information is available to all entities to check.
   * Returns true if the position overlaps a level tile 
   * @param x 
   * @param y 
   */
  public function hasAnyCollision(x:Int, y:Int) {
    return data.l_AutoIGrid.getInt(x, y) != 3;
  }

  public function hasAnyDecoration(x:Int, y:Int) {}

  public function hasAnyHazardCollision(x:Int, y:Int) {
    hazards.members.iter((hazard) -> {
      var hazardType = Type.getClass(hazard);
      switch (hazardType) {
        case _:
          // Do nothing
      }
    });
  }

  /**
   * Uses grid positions
   * @param x 
   * @param y 
   */
  public function hasExitCollision(x:Int, y:Int) {
    var bBox = new Bounds();
    return hazards.members.filter((hazard) -> Std.isOfType(hazard,
      en.hazard.Exit))
      .filter((el) -> {
        var exit:en.hazard.Exit = cast el;
        bBox.x = exit.colPoint.x;
        bBox.y = exit.colPoint.y;
        bBox.width = exit.colPoint.z;
        bBox.height = exit.colPoint.w;
        // trace(bBox.x);
        return bBox.contains(new Point(x, y));
      })
      .first();
  }

  /**
   * Transfers the player once they interact with an exit
   * within the game.
   * @param exit 
   */
  public function transferPlayer(exit:Exit) {
    player.cx = Std.int(exit.startPoint.x);
    player.cy = Std.int(exit.startPoint.y);
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

    // Render Floor Walls and Decorations
    var tlGroup = data.l_Floor.render();
    data.l_Walls.render(tlGroup);
    data.l_Decoration.render(tlGroup);
    root.addChild(tlGroup);
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