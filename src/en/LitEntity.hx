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

function setupEntity(entity:LitEntity, enForm:Entity) {
  entity.isLit = false;
  entity.complete = true;
  entity.point = new Point(enForm.spr.x, enForm.spr.y);
}

function handleLightInteraction(entity:LitEntity, enForm:Entity) {
  var level = enForm.level;
  entity.point.x = enForm.spr.x;
  entity.point.y = enForm.spr.y;
  // Refactor later into the level update function
  if (!enForm.cd.has('lightTransition')) {
    var inCone = level.player.lightCollider.contains(entity.point);
    if (!entity.isLit && inCone && level.player.flashLight.isOn()) {
      entity.isLit = true;
      entity.complete = false;
      level.tw.createS(enForm.spr.alpha, 1, TEase, 2).end(() -> {
        entity.complete = true;
      });
      enForm.cd.setS('lightTransition', 2);
    } else if (entity.isLit && !inCone) {
      entity.isLit = false;
      entity.complete = false;
      level.tw.createS(enForm.spr.alpha, 0, TEase, 2).end(() -> {
        entity.complete = true;
      });
      enForm.cd.setS('lightTransition', 2);
    }
  }
}