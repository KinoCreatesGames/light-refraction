package ui.transition;

import GameTypes.ShadeTransition;
import haxe.display.Position.Range;
import h3d.mat.Texture;
import h3d.Vector;
import shaders.TransitionShader;

class ShaderTransition extends dn.Process {
  public static inline var TRANSITION_TIME:Float = 1.5;

  public var transitionTween:Tweenie;
  public var completePass:Bool;
  public var complete:Bool;
  public var time:Float;
  public var tween:Tween;
  public var shader:TransitionShader;

  public function new() {
    super(Game.ME);
    time = 0;
    complete = false;
    completePass = false;
    shader = new TransitionShader(Vector.fromColor(0x0), TRANSITION_TIME);
    shader.transitionTexture = Assets.transTex;
    shader.texture = new Texture(engine.width, engine.height, [Target]);
    // Setup tween
    transitionTween = new Tweenie(Const.FPS);
    tween = transitionTween.createS(time, TRANSITION_TIME, TEase,
      TRANSITION_TIME);

    tween.end(() -> {
      #if debug
      trace('End Shader Transition');
      #end
      completePass = true;
      cleanupTransition();
    });

    tween.start(() -> {
      #if debug
      trace('Start Shader Transition');
      #end
    });
  }

  public static function createTransition(sType:ShadeTransition) {
    var trans = new ShaderTransition();
    switch (sType) {
      case Radial:
        trans.shader.transitionTexture = Assets.transTex;
      case Custom:
        trans.shader.transitionTexture = Assets.transTex;
    }
    return trans;
  }

  public function cleanupShader() {
    if (Boot.ME != null) {
      Boot.ME.removeTransition();
    }
  }

  public function cleanupTransition() {
    tween = transitionTween.createS(time, 0, TEase, TRANSITION_TIME);
    tween.end(() -> {
      #if debug
      trace('End Shader Transition Final Pass');
      #end
      complete = true;
      cleanupShader();
    });

    tween.start(() -> {
      #if debug
      trace('Start Shader Transition Final Pass');
      #end
    });
  }

  override function update() {
    super.update();
    transitionTween.update();
    shader.time = this.time;
  }
}