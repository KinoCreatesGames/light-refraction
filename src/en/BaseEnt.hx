package en;

import h2d.Scene;

class BaseEnt extends Entity {
  public var health:Int;
  public var maxHealth:Int = 3;

  public var healthPerc(get, null):Float;

  public static inline var KNOCKBACK_FORCE:Float = 0.25;

  public static inline var KB_CD:Float = 0.3;

  public var scn(get, null):Scene;

  public inline function get_scn() {
    return Boot.ME.s2d;
  }

  public inline function get_healthPerc() {
    return health / maxHealth;
  }

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

  public var ready:Bool;

  public function new(x:Int, y:Int) {
    super(x, y);
    ready = false;
  }

  override function postUpdate() {
    super.postUpdate();
    // Standard post update, updates the sprite position
    // Once updated we'll consider the entity ready
    ready = true;
  }

  /**
   * Knockbacks the character in the opposite
   * direction then the one that they're going in at the time.
   * In addition sets the cd to 'knockback'.
   */
  public function knockback() {
    ext.HTools.knockback(this, KNOCKBACK_FORCE, KB_CD);
    this.setSquashX(0.8);
  }
}