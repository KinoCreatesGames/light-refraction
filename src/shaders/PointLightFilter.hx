package shaders;

import h3d.shader.ScreenShader;
import hxsl.Dce;
import h3d.shader.Base2d;
import h3d.Vector;
import h3d.mat.Texture;

class PointLightFilter extends h2d.filter.Shader<InternalShader> {
  public function new() {
    super(new InternalShader());
  }

  public inline function setWidthHeight(width:Float, height:Float) {
    shader.widthHeight.x = width;
    shader.widthHeight.y = height;
  }

  public inline function setColor(color:Int) {
    shader.color = Vector.fromColor(color);
  }

  public inline function setPos(x:Float, y:Float) {
    shader.pos.x = x;
    shader.pos.y = y;
  }
}

/**
 * 2D PointLight Shader
 * that allows you to create a spotlight effect
 * within your game similar
 * to the Pokemon franchise games in the caves.
 */
private class InternalShader extends ScreenShader {
  static var SRC = {
    // @:import h3d.shader.ScreenShader; Necessary for base 2D Shaders

    /**
     * The radius of the circle that
     * makes the spotlight in the middle of the screen
     * 
     */
    @param var radius:Float;

    /**
     * The strength of the dimming 
     * on the rest of the screen
     */
    @param var strength:Float;

    /**
     * The width / height of the game engine screen
     * in order to correct the circle
     */
    @param var widthHeight:Vec2;

    /**
     * The amount of buffer 
     * on the edges to create smooth edges
     * around the spotLight effect
     */
    @param var smoothEdges:Float;

    /**
     * The texture used to sample from that contains
     * the screen texture that we pull from for
     * rendering the new scene.
     */
    @param var texture:Sampler2D;

    /**
     * The player position on the screen to use as the center of the circle
     */
    @param var pos:Vec2;

    /**
     * Point Color  tint
     */
    @param var color:Vec4;

    function fragment() {
      // Room Color Without Lights
      var texColor = texture.get(input.uv);
      // Room color with the lights on
      //   var lights = texs.get(vec3(input.uv, 0));
      // Center  of the radial circle
      var movingCenter = vec2(pos.x / widthHeight.x, pos.y / widthHeight.y);
      // Screen center
      var center = vec2(.5, .5);
      // Correct for the resolution aspect ratio
      // We scale all elements on the x axis to have them stretch
      // To meet the Y coordinates
      var resolutionCorrect = vec2(widthHeight.x / widthHeight.y, 1.);
      // Percent away from the center
      var pct = distance(input.uv, center);
      // Smoothing
      var str = 1 - (smoothstep(0.1, radius + smoothEdges, pct));

      //   var tmp = texColor;
      //   texColor *= ((str));
      //   Smooth Edges
      // pixelColor = pixelColor;
      var cl = texColor;
      // cl.rg *= pct;
      // cl.b = pct;
      var uv = input.uv;
      // var uv = input.uv;
      uv.r = pct;
      cl.rgb = uv.rrr;
      // cl.rgb = vec3(uv.r, uv.r, uv.r);
      pixelColor = cl;
      // pixelColor = texColor * str;
    }
  }

  public function new(radius:Float = .5, smoothEdge:Float = 0.02,
      strength:Float = .3) {
    super();
    this.radius = radius;
    this.smoothEdges = smoothEdge;
    this.strength = strength;
  }
}