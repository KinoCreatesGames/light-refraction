package en;

import h2d.col.Point;

/**
 * Any  element that 
 * can have lights interact with it within the game.
 * This allows us to bring the controls across
 * different classes.
 */
interface LitEntity {
  public var point:Point;
  public var complete:Bool;

  /**
   * Returns whether the entity is lit within the game
   * and should be used to allow them to send information
   * to the entity to handle the interaction and also
   * provide information to the rest of the elemts within the game..
   */
  public var isLit:Bool;

  /**
   * Update function that handles light interacts
   * within the game and should be implemented
   * by that class when they're being used.
   */
  public function handleLightInteraction():Void;
}