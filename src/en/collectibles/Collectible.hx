package en.collectibles;

/**
 * A collectible within the game.
 * Collecting it will have an affect on other entities
 * within the game.
 */
class Collectible extends Entity {
  public function new(x:Int, y:Int) {
    super(x, y);
    setupGraphic();
  }

  public function setupGraphic() {}
}