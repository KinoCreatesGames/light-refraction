package shaders;

import h3d.shader.ScreenShader;
import h3d.Vector;
import h3d.mat.Texture;

/**
 * 2D Spotlight Shader
 * that allows you to create a spotlight effect
 * within your game similar
 * to the Pokemon franchise games in the caves.
 */
class SpotLightShader2D extends ScreenShader {
  static var SRC = {
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
    @param var tex:Sampler2D;

    function fragment() {
      var texColor = tex.get(input.uv);
      // Center  of the radial circle
      var center = vec2(.5, .5);
      // Correct for the resolution aspect ratio
      // We scale all elements on the x axis to have them stretch
      // To meet the Y coordinates
      var resolutionCorrect = vec2(widthHeight.x / widthHeight.y, 1.);
      // Percent away from the center
      var pct = distance(input.uv * resolutionCorrect,
        center * resolutionCorrect);
      // Smoothing
      var str = 1 - (smoothstep(0.1, radius + smoothEdges, pct));

      var tmp = texColor;
      texColor *= ((str));

      // Smooth Edges
      pixelColor = texColor + (tmp * strength);
    }
  }

  public function new(radius:Float = .1, smoothEdge:Float = 0.02,
      strength:Float = .3) {
    super();
    this.radius = radius;
    this.smoothEdges = smoothEdge;
    this.strength = strength;
  }
}