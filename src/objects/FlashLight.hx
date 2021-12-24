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
   * Creates a new flash light within the game.
   */
  public function new(color:Int = 0xffffff) {
    super(0, 0);
    on = false;
    batteryLife = 1.;
    this.color = color;
    this.drainPerc = 0.02;
  }

  public inline function isOn() {
    return this.on;
  }

  public inline function isOutOfBattery() {
    return this.batteryLife <= 0;
  }

  public function turnOn() {
    on = true;
  }

  public function turnOff() {
    on = false;
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