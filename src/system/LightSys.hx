package system;

import h2d.BlendMode;
import hxd.Timer;
import shaders.PointLightShader2D;
import h3d.Vector;
import h2d.col.Ray;
import h2d.col.Point;
import h2d.col.Polygon;

/**
 * Lighting system that handles the polygonal data
 * for constructing the lights within the scene.
 */
class LightSys {
  /**
   * Polygonal data for the game fed in through
   * the list of entities and elements on the map.
   */
  var levelPoly:Array<h2d.col.Polygon>;

  /**
   * Polygon created from the hit tests against the level Polygonal
   * data.
   */
  public var lightPoly:h2d.col.Polygon;

  /**
   * The polygon that contains the flashlight 
   * vision cone constructing from casted rays.
   */
  public var flashlightPoly:h2d.col.Polygon;

  /**
   * Origin of the flashlight starting point for 
   * ray casting.
   */
  public var flOrigin:Point;

  /**
   * Radius of the flash light
   * for terminal point.
   */
  public var flRadius:Float;

  /**
   * Level data for generating polygonal information.
   */
  var data:LDTkProj_Level;

  public var lightPoint:Point;

  var lightRays:Array<Ray>;
  var intersectionPoints:Array<Point>;
  var lightRadius = 40;
  var polyPoints:Array<Point>;

  public var lightG:h2d.Graphics;

  public var pointLights:Array<PointLight>;

  /**
   * Create the lighting system for use within the game on a specific level.
   */
  public function new(level) {
    levelPoly = [];
    lightRays = [];
    intersectionPoints = [];
    polyPoints = [];
    pointLights = [];
    lightPoly = new Polygon();
    flashlightPoly = new Polygon();
    var shader = new PointLightShader2D();
    lightG = new h2d.Graphics();
    lightG.addShader(shader);
    lightPoint = new Point(150, 150);
    flOrigin = lightPoint.clone();
    flRadius = lightRadius;
    // Create Test Point Light
  }

  public function gatherLevelInfo(level:Level, data:LDTkProj_Level) {
    // Turn entities into polygonal data
    this.data = data;
    var test = new PointLight(lightPoint.clone(), level.root, data);
    pointLights.push(test);
  }

  public function castLight() {
    lightRays.resize(0);
    intersectionPoints.resize(0);
    polyPoints.resize(0);
    // castPointLights();
    // castFlashlight();
  }

  public function castPointLights() {
    var lineSegments = levelPoly.flatMap((poly) -> poly.toSegments());
    var rayAmount = 30;
    var radius = 360;
    var angleSplit = (360 / rayAmount);
    var totalAng = 0;

    var createAllRays = (pOne:Point, pTwo:Point) -> {
      var dist = pOne.distance(pTwo);
      var rot = 5.toRad();
      var rayOne = Ray.fromPoints(pOne, pTwo);
      var rotPoint = rayOne.getPoint(dist);
      var rotPointTwo = rotPoint.clone();
      rotPoint.rotate(rot);
      rotPointTwo.rotate(-rot);
      var rotatedRay = Ray.fromPoints(pOne, rotPoint);
      var rotatedRayTwo = Ray.fromPoints(pOne, rotPointTwo);
      lightRays.push(rayOne);
      lightRays.push(rotatedRay);
      lightRays.push(rotatedRayTwo);
    }

    for (amount in 0...rayAmount) {
      var rad = (angleSplit * amount).toRad();
      var start = new Point(0, 0);
      var endP = new Point(start.x + lightRadius, start.y);
      endP.rotate(rad);
      var ray = Ray.fromPoints(start, endP);
      ray.px = lightPoint.x;
      ray.py = lightPoint.y;
      lightRays.push(ray);
    }

    // for (segment in lineSegments) {
    //   var startPoint = new Point(segment.x, segment.y);
    //   var endPoint = new Point(segment.x + segment.dx, segment.y + segment.dy);

    //   // endPoint.scale(2); // Adding after rotation negates rotations
    //   createAllRays(lightPoint, endPoint);
    //   createAllRays(lightPoint, startPoint);
    // }
    // Check Collision by splitting polygons into segments and recording points
    var checkList = [];
    var rayIndex = 0;
    // trace(lightRays.length);
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
          var flP = ray.getPoint((result.distance(lightPoint)));
          flP.x = M.floor(flP.x);
          flP.y = M.floor(flP.y);
          if (result.x.isValidNumber()
            && result.distance(lightPoint) <= lightRadius
            && flP.equals(flooredResult)
            && !checkList.contains(rayIndex)) {
            intersectionPoints.push(result);
            checkList.push(rayIndex);
          }
        }
      });
      if (!checkList.contains(rayIndex)) {
        var radPoint = ray.getPoint(lightRadius);
        if (!levelPoly.exists((poly) -> poly.contains(radPoint)))
          polyPoints.push(radPoint);
        checkList.push(rayIndex);
      }
      rayIndex++;
    }
    // trace('Ray Result Matches ${intersectionPoints}');
    // trace(intersectionPoints.length);
  }

  public function castFlashlight() {
    // // Construct light as  radius polygon
    // // Flashlight Radius
    // var lineSegments = levelPoly.flatMap((poly) -> poly.toSegments());
    // var rayAmount = 30;
    // var angleSplit = (90 / 30).toRad();
    // var start = new Point(0, 0);
    // for (amount in rayAmount) {
    //   var endPoint = start.clone();
    //   endPoint.rotate(amount * angleSplit);
    //   Ray.fromPoints(start, endPoint);
    // }
  }

  public function convertoToPolygons() {
    // Gather tile information
    // Scan Map tiles
    // Size of the grid view of the map for scanning
    // Auto Grid is used for laying down all level layout tiles excluding entities
    var cellWidth = data.l_AutoIGrid.cWid;
    var cellHeight = data.l_AutoIGrid.cHei;
    var gridS = data.l_AutoIGrid.gridSize;
    var endX = 0;
    var endY = 0;
    var startX = 0;
    var startY = 0;
    var currentTile = null;
    var polygon:Polygon = null;
    var gridT = null;
    var tileId = null;
    for (y in 0...cellHeight) {
      for (x in 0...cellWidth) {
        var tileTest = data.l_AutoIGrid.getInt(x, y);
        // Initial check for new lines
        if (tileId != null && tileTest == 3) {
          var pt = new Point(endX + gridS, startY);
          polygon.push(pt);
          var ptThree = new Point(endX + gridS, endY + gridS);
          polygon.push(ptThree);
          var ptTwo = new Point(startX, endY + gridS);
          polygon.push(ptTwo);
          polygon.push(new Point(startX, startY));
          // trace('Close polygon ${startX} ${startY} ${endX}, ${endY}');
          levelPoly.push(polygon);
          tileId = null;
        }
        // Create a new polygon when the tile ID is null aka start
        // Tile can't be floor

        if (tileId == null && tileTest != 3) {
          tileId = tileTest;
          polygon = new Polygon();
          startX = x * gridS;
          startY = y * gridS;
          // trace('Create polygon ${startX} ${startY}');
          var pt = new Point(startX, startY);
          polygon.push(pt);
        }
        // If Tile ID is not null and we find a floor tile close the polygon
        if (tileId != null && tileTest == 3) {
          // trace('Close polygon ${endX}, ${endY}');
          endX = x * gridS;
          endY = y * gridS;
          var pt = new Point(endX, endY);
          polygon.push(pt);
          var ptThree = new Point(endX, endY + gridS);
          polygon.push(ptThree);
          var ptTwo = new Point(startX, endY + gridS);
          polygon.push(ptTwo);
          polygon.push(new Point(startX, startY));
          tileId = null;
          levelPoly.push(polygon);
        }
        // At the end of the row set a new endX
        endX = x * gridS;
        endY = y * gridS;
      }
      // If final polygon not closed and at the end close it.
      if (tileId != null && y == cellHeight - 1) {
        // trace('Close polygon ${endX}, ${endY}');
        var pt = new Point(endX + gridS, endY);
        polygon.push(pt);
        var ptThree = new Point(endX + gridS, endY + gridS);
        polygon.push(ptThree);
        var ptTwo = new Point(startX, endY + gridS);
        polygon.push(ptTwo);
        polygon.push(new Point(startX, startY));
        tileId = null;
        levelPoly.push(polygon);
      }
    }
    var test = pointLights.first();
    test.gatherInfo(levelPoly);
    test.castLight();
  }

  public function debugDraw(level:Level) {
    // trace('Polygon count ${levelPoly.length}');
    // for (poly in levelPoly) {
    //   var graphic = new h2d.Graphics(level.root);
    //   graphic.beginFill(0xffffff);
    //   for (point in poly.points) {
    //     graphic.lineTo(point.x, point.y);
    //   }
    //   graphic.endFill();
    // }
    var test = pointLights.first();

    test.renderLight();

    lightG.clear();
    level.root.addChild(lightG);
    // for (ray in lightRays) {
    //   // var graphic = new h2d.Graphics(level.root);
    //   lightG.lineStyle(1, 0xff0000, 1);
    //   lightG.beginFill(0xff0000);
    //   lightG.lineTo(ray.px, ray.py);
    //   var endP = ray.getPoint(lightRadius);
    //   lightG.lineTo(endP.x, endP.y);
    //   lightG.endFill();
    // }

    var finalPoints = polyPoints.concat(intersectionPoints);
    // TODO: Start getting the closest intersections
    // Sort Intersection by angle
    finalPoints.sort((pOne, pTwo) -> {
      var angOne = M.angTo(lightPoint.x, lightPoint.y, pOne.x, pOne.y);
      var angTwo = M.angTo(lightPoint.x, lightPoint.y, pTwo.x, pTwo.y);
      // trace('Angles ${angOne} ${angTwo}');
      return angOne < angTwo ? -1 : 1;
      // return M.floor((M.fabs(angOne - angTwo) * 100);
    });

    // graphic.lineStyle(1, 0xaa00ff, 1);
    // graphic.color.r *= point.y;

    // graphic.lineTo(lightPoint.x, lightPoint.y);
    // var fp = intersectionPoints[0];
    // var sp = intersectionPoints[1];

    // graphic.lineTo(sp.x, sp.y);
    // // graphic.lineTo(fp.x, fp.y);
    // trace(sp.x);
    // trace(fp.x);
    // var pG = new h2d.Graphics(level.root);
    // for (point in intersectionPoints) {
    //   lightG.beginFill(0x00ffaa);
    //   lightG.drawCircle(point.x, point.y, 3);
    // }
    // lightG.endFill();
    var start = 0;

    var game = Game.ME;
    var shader = lightG.getShader(PointLightShader2D);
    shader.widthHeight.x = game.w();
    shader.widthHeight.y = game.h();
    shader.pos.x = lightPoint.x;
    shader.pos.y = lightPoint.y;
    shader.color = Vector.fromColor(0xff0ff0);
    // shader.sTime += Timer.elapsedTime;
    lightG.beginFill(0xaa00ff);
    var colors = [0x0a00ff, 0xff0000, 0x00ffaa];
    // trace(finalPoints.length);
    // trace(intersectionPoints.length);

    // for (point in finalPoints) {
    //   lightPoly.push(point);
    //   var c = lightG.color;
    //   // trace(point.x);
    //   // trace(point.y);
    //   var uv = (start / finalPoints.length);
    //   var uvTwo = (lightPoint.distance(point)) / lightRadius;
    //   lightG.addVertex(point.x, point.y, 1, 1, c.b, uvTwo, uvTwo);
    //   var color = 0xffffff;
    //   // var finalC = C.offsetColorInt(color, Std.int(start * 10));
    //   // lightG.lineStyle(1, colors[start % colors.length], 1);

    //   // lightG.lineTo(lightPoint.x, lightPoint.y);
    //   // lightG.lineTo(point.x, point.y);
    //   // graphic.beginFill(0x00ffaa);
    //   // lightG.drawCircle(point.x, point.y, 3);
    //   // // trace(point.x);
    //   // trace(point.x);
    //   // trace(point.y);
    //   // graphic.endFill();
    //   start++;
    //   //
    // }
    // lightG.blendMode = BlendMode.SoftAdd;
    // lightG.color.a = 0.7;

    // graphic.endFill();
    // graphic.drawRect(0, 0, 300, 400);
    // graphic.endFill();
  }
}