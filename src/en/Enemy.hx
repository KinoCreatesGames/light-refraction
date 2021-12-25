package en;

class Enemy extends Entity {
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

  public function setup() {}
}