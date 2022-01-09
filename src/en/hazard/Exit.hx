package en.hazard;

import h3d.Vector;

/**
 * Exits that take the player to the next level.
 * Triggers transitions and moving to the next screen.
 */
class Exit extends Hazard {
  public var lvlName:String = '';

  /**
   * Contains the grid coordinates of the exit point
   * on the map.
   *  Also contains the width, height of the coordinate 
   * as well.
   */
  public var colPoint:Vector;

  /**
   * Contains the x, y coordinate of the spawn point.
   */
  public var startPoint:Vector;

  public function new(exit:Entity_Exit) {
    super(exit.cx, exit.cy);
    lvlName = exit.f_LevelTagName;
    startPoint = new Vector(exit.f_spawnX, exit.f_spawnY);
    colPoint = new Vector(exit.cx, exit.cy, M.floor(exit.width / Const.GRID),
      M.floor(exit.height / Const.GRID));
  }
}