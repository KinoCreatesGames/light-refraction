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

  var lightRadius = 40;

  public var lightG:h2d.Graphics;

  public var pointLights:Array<PointLight>;
  public var flashLight:FlashLight;

  /**
   * Create the lighting system for use within the game on a specific level.
   */
  public function new(level:Level) {
    levelPoly = [];

    pointLights = [];
    lightPoly = new Polygon();
    flashlightPoly = new Polygon();
    var shader = new PointLightShader2D();
    lightG = new h2d.Graphics();
    lightG.addShader(shader);
    lightPoint = new Point(150, 150);
    flOrigin = lightPoint.clone();
    flRadius = lightRadius;
    this.data = level.data;
    gatherLevelInfo(level, this.data);
    // Create Test Point Light
  }

  public function gatherLevelInfo(level:Level, data:LDTkProj_Level) {
    // Turn entities into polygonal data
    var p = lightPoint.clone();
    p.y -= 40;
    p.x += 20;
    var test = new PointLight(p, level.root, data);
    var testTwo = new system.FlashLight(lightPoint.clone(), 0xf101ff, 30, 60.,
      level.root, data);
    flashLight = testTwo;
    testTwo.lightRadius = 160;
    pointLights.push(test);
    pointLights.push(testTwo);
  }

  public function castLight() {
    // castPointLights();
    // castFlashlight();
    flashLight.castLight();
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

    // Cast the point lights after drawing polygonal data
    for (light in pointLights) {
      light.gatherInfo(levelPoly);
      light.castLight();
    }
  }

  public function renderLight() {
    for (light in pointLights) {
      light.renderLight();
    }
    if (Game.ME.level != null) {
      var player = Game.ME.level.player;
      flashLight.origin.x = player.spr.x;
      flashLight.origin.y = player.spr.y;
      var abs = player.spr.getAbsPos();
      flashLight.absCoords = new Point(abs.x, abs.y);
    }
  }

  public function debugDraw(level:Level) {
    for (light in pointLights) {
      light.debugDraw();
    }
  }
}