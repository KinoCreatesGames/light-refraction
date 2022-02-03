package en.hazard;

import h2d.col.Point;

class MovingPlatform extends Hazard implements LitEntity {
  public var path:Array<Point>;
  public var looping:Bool;
  public var pointIndex = 0;
  public var speed:Float;
  public var point:Point;
  public var complete:Bool;
  public var isLit:Bool;

  public static inline var INITIAL_WAIT:Float = 3;

  /**
   * Wait time between the destinations per point
   */
  public var waitTime:Float;

  public var reachedFinalDestination:Bool;

  public function new(mp:Entity_MovingPlatform) {
    super(mp.cx, mp.cy);
    looping = mp.f_loop;
    path = mp.f_Path.map((p) -> p.LDPtoPoint());
    waitTime = INITIAL_WAIT;
    reachedFinalDestination = false;
    this.spr.alpha = 0;
    LitEntity.setupEntity(this, this);
    cd.setS('initialWait', INITIAL_WAIT);
  }

  override function update() {
    super.update();
    if (!cd.has('initialWait')) {
      updatePath();
    }
    handleLightInteraction();
  }

  public function updatePath() {
    var point = path[pointIndex % path.length];
    if ((point.x != cx || point.y != cy) && !reachedFinalDestination) {
      var dest = point.toVec().normalized();
      dx = dest.x * speed;
      dy = dest.y * speed;
    } else {
      // Hit the final point destination
      if (pointIndex == (path.length - 1) && !looping) {
        reachedFinalDestination = true;
      } else if (pointIndex == (path.length - 1) && looping) {
        // Reverse the points and continue moving
        path.reverse();
      }
      if (!cd.has('platformStep')) {
        pointIndex++;
        cd.setS('platformStep', waitTime);
      }
    }
  }

  public function handleLightInteraction() {
    LitEntity.handleLightInteraction(this, this, 2, Const.PLAT_FADE_TIME);
  }
}