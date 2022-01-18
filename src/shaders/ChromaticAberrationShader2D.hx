package shaders;

import h3d.shader.ScreenShader;

/**
 * Chromatic Aberration Shader for the screen
 * based off the shader toy here: https://www.shadertoy.com/view/Mds3zn#
 */
class ChromaticAberrationShader2D extends ScreenShader {
  static var SRC = {
    /**
     * the amount of Chromatic Aberration to have
     */
    @param var amount:Float;

    /**
     * The texture aka, render texture to use
     * when sampling the screen for what to display.
     */
    @param var texture:Sampler2D;

    function fragment() {
      var uv = input.uv;
      // slightly adjusts the color sampling at the current UV Coordinate
      // This shifts the colo shown at the pixel by the offset
      // of the UV coordinate, creating the effect
      pixelColor.r = texture.get(vec2(uv.x + amount, uv.y)).r;
      pixelColor.g = texture.get(uv).g;
      pixelColor.b = texture.get(vec2(uv.x - amount, uv.y)).b;
      pixelColor = pixelColor;
    }
  }

  public function new(amount:Float = 0.025, tex:h3d.mat.Texture) {
    super();
    this.amount = amount;
    this.texture = tex;
  }
}