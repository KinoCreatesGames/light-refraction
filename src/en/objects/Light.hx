package en.objects;

class Light extends Entity {
  public var light:h2d.Graphics;

  public var isOn:Bool;

  public var graphic:h2d.Graphics;

  public function turnOff() {}

  public function turnOn() {}

  public function hideGraphic() {
    graphic.visible = false;
  }

  public function showGraphic() {
    graphic.visible = true;
  }
}