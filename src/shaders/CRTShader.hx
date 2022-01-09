package shaders;

import h3d.shader.ScreenShader;

/**
 * CRT screen effect based off 
 * the PIXI.js screen filter.
 * https://github.com/pixijs/filters/blob/main/filters/crt/src/CRTFilter.ts
 * https://github.com/pixijs/filters/blob/main/filters/crt/src/crt.frag
 */
class CRTShader extends ScreenShader {
  static var SRC = {
    @param var tex:Sampler2D;

    /**
     * the width of the CRT lines
     */
    @param var lineWidth:Float;

    /**
     * The contrast between the lines
     */
    @param var lineContrast:Float;

    /**
     * The width / height of the game engine screen
     * in order for resolution correction.
     */
    @param var widthHeight:Vec2;

    /**
     * The time within the 
     * game to allow for movement within the scan lines.
     */
    @param var time:Float;

    function fragment() {
      var pxColor = tex.get(input.uv);
      var uv = input.uv;
      var dir = vec2(uv.xy + vec2(0.5, 0.5));
      // pxColor.rgb = vec3(.5, .5, .5);
      // Reduce lines closer to the center
      var center = vec2(.5, .5);
      var resolutionCorrect = vec2(widthHeight.x / widthHeight.y, 1.);
      var pct = 1
        - distance(input.uv * resolutionCorrect, center * resolutionCorrect);
      var str = 1 - (smoothstep(0.1, .8, pct));

      if (lineWidth > 0.0) {
        // Curvature
        var curvature = 1.;
        // Create Lines within the pixels by using gradation of the colors
        var lineGradation = (uv.y * widthHeight.y) * min(1.0,
          2.0 / lineWidth) / curvature;
        var lineColor = 1.
          + ((cos(lineGradation * 1.2 - time)) * .5 * lineContrast) * str;

        pxColor *= lineColor;

        // Segment adjusts the color of the pixel
        var segment = 1 + mod((dir.y + .5) * widthHeight.y, 4.);
        pxColor.rgb *= clamp(.99 * ceil(segment) * 0.015, .5, 1.5);
        // Brighten lines and add more blue
        pxColor.rgb *= 1.5;
        pxColor.b *= (1.15);
      }
      pixelColor = pxColor;
    }
  }

  public function new(lineWidth:Float = 5., lineContrast:Float = .1) {
    super();
    this.lineWidth = lineWidth;
    this.lineContrast = lineContrast;
    this.time = 0;
  }
}