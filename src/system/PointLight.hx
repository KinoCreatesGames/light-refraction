package system;

import h3d.Vector;
import shaders.PointLightShader2D;
import hxd.Timer;
import h2d.BlendMode;
import h2d.col.Point;
import h2d.col.Polygon;
import h2d.col.Segment;
import h2d.Object;
import h2d.col.Ray;
import h2d.Drawable;

/**
 * 
 * Point light for
 * showing on the game screen.
 * Encapsules all the necessary components
 * for rendering a light within the game.
 */
class PointLight extends Drawable {
  public var game(get, null):Game;

  public inline function get_game() {
    return Game.ME;
  }

  public var lightPoly:h2d.col.Polygon;

  public var lightRays:Array<Ray>;

  public var lightG:h2d.Graphics;

  public var data:LDTkProj_Level;

  public var lvlSegments:Array<Segment>;

  /**
   * Level polygon for intersection testing against.
   */
  public var lvlPoly:Array<h2d.col.Polygon>;

  public var lightRadius:Float;

  public var origin:Point;

  public var polyPoints:Array<Point>;

  public var level(get, null):Level;

  public var angle:Float;

  /**
   * Color of the light within the game.
   */
  public var lColor:Int = 0xffffff;

  /**
   * Number of rays to use when constructing
   * the light source.
   */
  public var rayAmount:Int;

  public inline function get_level() {
    return Game.ME.level;
  }

  public function new(origin:Point, color = 0xffffff, rayAmount:Int = 30,
      angle:Float = 360., parent:Object, data:LDTkProj_Level) {
    super(parent);
    this.lColor = color;
    this.data = data;
    this.rayAmount = rayAmount;
    lightPoly = new h2d.col.Polygon();
    polyPoints = [];
    lightRays = [];
    this.angle = angle;
    lightG = new h2d.Graphics(parent);
    lightRadius = 40;
    this.origin = origin;
    setup();
  }

  public function setup() {
    var shader = new PointLightShader2D();
    shader.widthHeight.x = game.w();
    shader.widthHeight.y = game.h();
    shader.pos.x = this.origin.x;
    shader.pos.y = this.origin.y;
    shader.color = Vector.fromColor(lColor);
    lightG.addShader(shader);
  }

  public function gatherInfo(lPoly:Array<Polygon>) {
    lvlPoly = lPoly;
    lvlSegments = lvlPoly.flatMap((poly) -> poly.toSegments());
  }

  /**
   * Casts the light so that we can render it onto
   * the scene within the game.
   */
  public function castLight() {
    lightRays.resize(0);
    polyPoints.resize(0);
    var checkList = [];
    var rayIndex = 0;
    var lineSegments = lvlSegments;
    var angleSplit = (angle / rayAmount);

    // Create Rays
    for (amount in 0...rayAmount) {
      var rad = (angleSplit * amount).toRad();
      var start = new Point(0, 0);
      var endP = new Point(start.x + lightRadius, start.y);
      endP.rotate(rad);
      var ray = Ray.fromPoints(start, endP);
      ray.px = origin.x;
      ray.py = origin.y;
      lightRays.push(ray);
    }

    for (ray in lightRays) {
      var result = null;
      lineSegments.iter((segment) -> {
        // Only add ray cast hits that are within the light radius
        // Heaps segments intersect on both sides for ray?
        // Look into this later
        result = segment.lineIntersection(ray);

        var lP = ray.getPoint(lightRadius);
        if (result != null) {
          var flooredResult = result.clone();
          flooredResult.x = M.floor(flooredResult.x);
          flooredResult.y = M.floor(flooredResult.y);
          var flP = ray.getPoint((result.distance(origin)));
          flP.x = M.floor(flP.x);
          flP.y = M.floor(flP.y);
          if (result.x.isValidNumber()
            && result.distance(origin) <= lightRadius
            && flP.equals(flooredResult)
            && !checkList.contains(rayIndex)) {
            // Points that hit the intersection
            polyPoints.push(result);
            checkList.push(rayIndex);
          }
        }
      });
      if (!checkList.contains(rayIndex)) {
        var radPoint = ray.getPoint(lightRadius);
        if (!lvlPoly.exists((poly) -> poly.contains(radPoint)))
          polyPoints.push(radPoint);
        checkList.push(rayIndex);
      }
      rayIndex++;
    }

    // Sort all of the rays into the proper order for casting them on screen
    lightPoly = polyPoints.copy();
  }

  public function renderLight() {
    var start = 0;

    lightG.clear();
    level.root.addChild(lightG);
    // trace(polyPoints.length);
    lightG.beginFill(lColor);
    for (point in polyPoints) {
      var c = lightG.color;
      var uvTwo = (origin.distance(point)) / lightRadius;
      lightG.addVertex(point.x, point.y, 1, 1, c.b, uvTwo, uvTwo);
    }
    lightG.blendMode = BlendMode.SoftAdd;
    lightG.color.a = 0.7;
    lightG.endFill();

    // var factor = M.fclamp(M.fabs(Math.sin(Timer.frameCount.toRad() * .85)) * 1.25,
    //   1, 1.25);
    // lightG.setScale(factor);
  }

  public function debugDraw() {
    lightG.clear();
    var start = 0;
    level.root.addChild(lightG);
    lightG.beginFill(lColor);
    // graphic.lineStyle(1, 0xaa00ff, 1);
    var colors = [0x0a00ff, 0xff0000, 0x00ffaa];
    for (point in polyPoints) {
      lightG.lineStyle(1, colors[start % colors.length], 1);

      lightG.lineTo(origin.x, origin.y);
      lightG.lineTo(point.x, point.y);
      //   graphic.beginFill(0x00ffaa);
      lightG.drawCircle(point.x, point.y, 3);

      // graphic.endFill();
      start++;
      //
    }
    lightG.blendMode = BlendMode.SoftAdd;
    lightG.color.a = 0.7;
    lightG.endFill();
  }
}