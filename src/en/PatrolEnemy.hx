package en;

import h2d.col.Point;

class PatrolEnemy extends Enemy {
  public var pathPoints:Array<Point>;
  public var looping:Bool;
  public var pointIndex = 0;
  public var speed:Float;
  public var initialWait = 3;
  public var id:String;

  /**
   * Wait time between destinations per point.
   */
  public var waitTime:Float;

  public var oneShot:Bool;
  public var reachedFinalDestination:Bool;

  public function new(x:Int, y:Int) {
    super(x, y);
    id = '${x}_${y}';
    looping = true;
    speed = 0.05;
    waitTime = 3;
    oneShot = false;
    // oneShot = movingPlat.f_oneShot;
    reachedFinalDestination = false;
    cd.setS('initialWait', initialWait);
  }

  override function update() {
    super.update();
    if (!cd.has('initialWait')) {
      followPath();
    }
  }

  public function followPath() {
    var point = pathPoints[pointIndex % pathPoints.length];
    if ((point.x != cx || point.y != cy) && !reachedFinalDestination) {
      // Follow the path by checking the distance from point
      var dest = new Vec2(point.x - cx, point.y - cy).normalize();
      dx = dest.x * speed;

      dy = dest.y * speed;
      // Fixes issue with collision on platforms with this setup
    } else {
      // Hit the final point
      if (pointIndex == (pathPoints.length - 1) && oneShot) {
        reachedFinalDestination = true;
      }
      if (!Game.ME.delayer.hasId('platformStop' + id)) {
        Game.ME.delayer.addS('platformStop' + id, () -> {
          pointIndex++;
        }, waitTime);
      }
    }
  }
}