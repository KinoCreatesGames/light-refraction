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
    @param var texs:Sampler2DArray;

    /**
     * The player position on the screen to use as the center of the circle
     */
    @param var playerPos:Vec2;

    function fragment() {
      // Room Color Without Lights
      var texColor = texs.get(vec3(input.uv, 1));
      // Room color with the lights on
      var lights = texs.get(vec3(input.uv, 0));
      // Center  of the radial circle
      var movingCenter = vec2(playerPos.x / widthHeight.x,
        playerPos.y / widthHeight.y);
      // Screen center
      var center = vec2(.5, .5);
      // Correct for the resolution aspect ratio
      // We scale all elements on the x axis to have them stretch
      // To meet the Y coordinates
      var resolutionCorrect = vec2(widthHeight.x / widthHeight.y, 1.);
      // Percent away from the center
      var pct = distance(input.uv * resolutionCorrect,
        movingCenter * resolutionCorrect);
      // Smoothing
      var str = 1 - (smoothstep(0.1, radius + smoothEdges, pct));

      var tmp = texColor;
      // Flash Light Adjustment
      if (lights.r > .99 && lights.g > .99 && lights.b > .99) {
        texColor *= 1;
      } else {
        texColor *= ((str));
      }

      // // Smooth Edges
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