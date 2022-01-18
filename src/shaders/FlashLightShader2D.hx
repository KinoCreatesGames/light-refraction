package shaders;

class FlashLightShader2D extends hxsl.Shader {
  static var SRC = {
    @:import h3d.shader.Base2d;

    /**
     * The strength of the 
     * light when applied to the screen
     */
    @param var strength:Float;

    /**
     * The amount of buffer
     * on the edge of the light
     * to create a smooth light effect.
     */
    @param var smoothEdges:Float;

    function fragment() {
      var uv = input.uv;
      var center = vec2(0, 0);
      pixelColor.a = (1 - distance(uv, center) * 1.1);
      // pixelColor.r = uv.x;
      // pixelColor.b = uv.y;
      // pixelColor.g = 0;
      pixelColor = pixelColor;
    }
  }

  public function new(smoothEdge:Float = 0.02, strength:Float = .8) {
    super();
    this.strength = strength;
    this.smoothEdges = smoothEdge;
  }
}