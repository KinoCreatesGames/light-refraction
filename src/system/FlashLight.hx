package system;

import hxd.Timer;
import h3d.Vector;
import shaders.PointLightShader2D;
import h2d.col.Ray;
import h2d.col.Point;
import h2d.BlendMode;

class FlashLight extends PointLight {
  public var absCoords:Point = new Point(0, 0);
  public var batteryLife = 1.;
  public var on:Bool = false;
  public var cd:dn.Cooldown = new dn.Cooldown(Const.FPS);
  public var drainPerc:Float = 0.02;

  public inline function isOn() {
    return this.on;
  }

  public inline function turnOn() {
    on = true;
    lightG.visible = on;
  }

  public inline function turnOff() {
    on = false;
    lightG.visible = on;
  }

  public function update() {
    cd.update(Timer.tmod);
    updateBatteryDrain();
  }

  public function updateBatteryDrain() {
    if (on) {
      if (!cd.has('drain')) {
        cd.setS('drain', 1, () -> {
          batteryLife -= drainPerc;
        });
      }
    }

    if (batteryLife <= 0) {
      turnOff();
    }
  }

  override function setup() {
    var shader = new PointLightShader2D();
    shader.widthHeight.x = game.w();
    shader.widthHeight.y = game.h();
    shader.pos.x = this.origin.x;
    shader.pos.y = this.origin.y;
    shader.color = Vector.fromColor(lColor);
    lightG.alpha = 0.7;
    // lightG.addShader(shader);
  }

  override function castLight() {
    lightRays.resize(0);
    polyPoints.resize(0);
    var scn = Boot.ME.s2d;
    var abs = absCoords;
    var pToM = new Point(scn.mouseX - (abs.x),
      scn.mouseY - (abs.y)).normalized();
    var rotation = M.angTo(0, 0, pToM.x, pToM.y);
    var checkList = [];
    var rayIndex = 0;
    var lineSegments = lvlSegments;
    var angleSplit = (angle / rayAmount);
    // trace(rotation.toDeg());

    // Create Rays
    for (amount in 0...rayAmount) {
      var rad = (angleSplit * amount).toRad() + rotation;
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
    // polyPoints.sort((pOne, pTwo) -> {
    //   var angOne = M.angTo(origin.x, origin.y, pOne.x, pOne.y);
    //   var angTwo = M.angTo(origin.x, origin.y, pTwo.x, pTwo.y);
    //   // trace('Angles ${angOne} ${angTwo}');
    //   return angOne > angTwo ? -1 : 1;
    //   // return M.floor((M.fabs(angOne - angTwo) * 100);
    // });
    lightPoly = polyPoints.copy();
  }

  override function debugDraw() {
    lightG.clear();
    var start = 0;

    lightG.beginFill(lColor);
    // graphic.lineStyle(1, 0xaa00ff, 1);
    // lightG.lineTo(origin.x, origin.y);
    // lightG.addVertex(origin.x, origin.y, 1, 1, 1, 1);
    var colors = [0x0a00ff, 0xff0000, 0x00ffaa];
    lightG.lineStyle(1, colors[start % colors.length], 1);
    for (point in polyPoints) {
      var c = lightG.color;

      //   lightG.addVertex(point.x, point.y, 1, 1, c.b, uvTwo, uvTwo);
      // lightG.lineTo(origin.x, origin.y);
      if (start % 2 == 0) {
        lightG.drawCircle(point.x, point.y, 3);
      }
      lightG.lineTo(point.x, point.y);
      start++;
    }
    lightG.lineTo(origin.x, origin.y);
    // lightG.addVertex(origin.x, origin.y, 1, 1, 1, 1);
    lightG.blendMode = BlendMode.SoftAdd;
    lightG.color.a = 0.7;
    lightG.endFill();
    // lightG.rotation += hxd.Timer.elapsedTime;
  }

  override public function renderLight() {
    lightG.clear();
    var start = 0;

    lightG.beginFill(lColor);
    // graphic.lineStyle(1, 0xaa00ff, 1);
    // lightG.lineTo(origin.x, origin.y);
    lightG.addVertex(origin.x, origin.y, 1, 1, 1, 1);
    var colors = [0x0a00ff, 0xff0000, 0x00ffaa];
    // lightG.lineTo(origin.x, origin.y);
    for (point in polyPoints) {
      var c = lightG.color;
      var uvTwo = (origin.distance(point)) / lightRadius;
      //   lightG.addVertex(point.x, point.y, 1, 1, c.b, uvTwo, uvTwo);
      lightG.lineTo(point.x, point.y);
    }
    // lightG.lineTo(origin.x, origin.y);
    // lightG.addVertex(origin.x, origin.y, 1, 1, 1, 1);
    lightG.blendMode = BlendMode.SoftAdd;
    lightG.color.a = 0.7;
    lightG.endFill();
    // lightG.rotation += hxd.Timer.elapsedTime;
  }
}