package en;

class Enemy extends BaseEnt {
  /**
   * An enemy within them.
   * X, Y coordinates are the coordinates within the grid of the game.
   * @param x 
   * @param y 
   */
  public function new(x:Int, y:Int) {
    super(x, y);
    setup();
  }

  public function setup() {
    // Setup element within the game
    setupGraphics();
  }

  public function setupGraphics() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0xff0000);
    g.drawRect(0, 0, 8, 8);
    g.endFill();
  }
}