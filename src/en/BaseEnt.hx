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

  public function addHealth(value:Int) {
    health += value;
  }
}