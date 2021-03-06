package shaders;

import h3d.mat.TextureArray;
import h3d.shader.ScreenShader;
import h3d.Vector;
import h3d.mat.Texture;
import h3d.mat.TextureArray;

class CompositeShader extends ScreenShader {
  static var SRC = {
    /**
     * Render texture we use to make
     * screen modifications.
     */
    @param var textures:Sampler2DArray;

    @param var lightTexture:Sampler2D;

    /**
     * The in game hud, which is used
     * to render the hud over everything else.
     */
    @param var hudTexture:Sampler2D;

    /**
     * The color vector for tinting
     * the game with that specified color.
     */
    function fragment() {
      // Lit level
      var litTexColor = textures.get(vec3(input.uv, 1));
      // Unlit Level
      var texColor = textures.get(vec3(input.uv, 0));
      // HUD
      // Room color with the lights on
      var lights = lightTexture.get(input.uv);
      // var texThree = textures.get(vec3(input.uv, 2));
      var hud = hudTexture.get(input.uv);
      var result = texColor;

      var clResult = lights.r;
      clResult += lights.g;
      clResult += lights.b;

      var clHud = hud.r;
      clHud += hud.g;
      clHud += hud.b;
      lights *= 1.5;
      // lights.a = .3;

      if (clHud > 0) {
        result = hud;
      } else if (clResult > 0) {
        // lights.r += .3;
        // lights.r += 1;
        // result = litTexColor + lights * .3;
        lights.b *= 2;
        lights.r *= .3;
        lights.g *= .5;
        litTexColor.b *= 1.8;
        result = texColor * .5 + mix(litTexColor, lights, .75);
      }

      pixelColor = result;
    }
  }

  public function new(textures:TextureArray) {
    super();
    this.textures = textures;
  }
}