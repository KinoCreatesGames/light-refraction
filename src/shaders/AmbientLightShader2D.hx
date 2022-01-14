package shaders;

import h3d.shader.ScreenShader;

/**
 * 
 * Appliles an ambient light to the entire scene.
 * Light Can have a specific color among other things.
 */
class AmbientLightShader2D extends ScreenShader {
  static var SRC = {
    /**
     * The strength of the ambient light within the scene.
     */
    @param var strength:Float;

    /**
     * The texture render target to be passed into the scene
     * for the game.
     */
    @param var texture:Sampler2D;

    /**
     * 
     * The color of the ambient light within the scene
     * to affect the color of the screen
     * within your game.
     */
    @param var lightcolor:Vec3;

    function fragment() {
      var texColor = texture.get(input.uv);
      var result = lightColor * strength;
      pixelColor = (texColor * result);
    }
  }

  public function new(ambStrength:Float, tex:Texture) {
    super();
    this.strength = ambStrength;
    this.texture = tex;
  }
}