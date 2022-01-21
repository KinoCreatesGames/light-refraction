package en.hazard;

class Platform extends Hazard {
  public var isLit:Bool;

  public function new(pl:Platform) {
    super(pl.cx, pl.cy);
    isLit = false;
  }
}