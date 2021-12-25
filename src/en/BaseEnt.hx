package en;

class BaseEnt extends Entity {
  public var health:Int;

  /**
   * Based on what the health of the current character is.
   * Determines whether they're alive or dead.
   */
  public inline function isDead() {
    return health <= 0;
  }

  /**
   * Adds health to the character within the game.
   * @param value 
   */
  public function addHealth(value:Int) {
    health += value;
  }

  /**
   * Takes damage with a specified value, by default, it's set to 1.
   * @param value 
   */
  public function takeDamage(value:Int = 1) {
    health -= value;
  }
}