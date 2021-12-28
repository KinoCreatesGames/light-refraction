package graphics;

import h2d.col.Point;
import h2d.Graphics.GPoint;

class Graphics2DSv extends h2d.Graphics {
  public var savedPoints:Array<Point>;

  override function clear() {
    super.clear();
    savedPoints = [];
  }

  public override function drawPie(cx:Float, cy:Float, radius:Float,
      angleStart:Float, angleLength:Float, nsegments = 0) {
    if (Math.abs(angleLength) >= Math.PI * 2) {
      return drawCircle(cx, cy, radius, nsegments);
    }
    flush();
    lineTo(cx, cy);
    if (nsegments == 0) {
      nsegments = Math.ceil(Math.abs(radius * angleLength / 4));
    }
    if (nsegments < 3) {
      nsegments = 3;
    }
    var angle = angleLength / (nsegments - 1);
    for (i in 0...nsegments) {
      var a = i * angle + angleStart;
      lineTo(cx + Math.cos(a) * radius, cy + Math.sin(a) * radius);
    }
    lineTo(cx, cy);
    savedPoints = tmpPoints.map((gp) -> {
      return new Point(gp.x, gp.y);
    });
    flush();
  }
}