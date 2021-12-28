package objects;

import hxd.Timer;

/**
 * An object that represents an in game flashlight.
 * Has elements to control the flash light in terms of what's going on
 * within the game.
 */
class FlashLight extends Entity {
  /**
   * Whether the flashlight is on or off.
   */
  public var on:Bool;

  /**
   * The life of the flash light battery.
   */
  public var batteryLife:Float;

  /**
   * The amount of power to drain from the battery over time
   * while it's on every second.
   * By default this is set to 0.02;
   */
  public var drainPerc:Float;

  public var color:Int;

  /**
   * Flashlight graphic using PI Shape.
   */
  public var lightG:h2d.Graphics;

  /**
   * The range of the light 
   * that defines how far the cone sticks out from.
   */
  public var lightRange:Float;

  /**
   * Creates a new flash light within the game.
   */
  public function new(color:Int = 0xffffff, lightRange:Float = 5) {
    super(0, 0);
    on = false;
    batteryLife = 1.;
    this.color = color;
    this.drainPerc = 0.02;
    this.lightRange = lightRange * Const.GRID;
    setup();
  }

  public function setup() {
    // Setup graphics
    lightG = new h2d.Graphics(spr);
    lightG.blendMode = Alpha;
    // lightG.alpha = 0.0;
    lightG.beginFill(this.color);
    var start = 0.toRad();
    var end = 60.toRad();
    lightG.drawPie(cx, cy, lightRange, start, end);
    lightG.endFill();
  }

  public inline function isOn() {
    return this.on;
  }

  public inline function isOutOfBattery() {
    return this.batteryLife <= 0;
  }

  public function turnOn() {
    on = true;
    lightG.visible = on;
  }

  public function turnOff() {
    on = false;
    lightG.visible = on;
  }

  public override function update() {
    super.update();
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
  }
}