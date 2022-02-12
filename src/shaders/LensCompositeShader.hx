package shaders;

import h3d.mat.TextureArray;
import h3d.shader.ScreenShader;
import h3d.Vector;
import h3d.mat.Texture;
import h3d.mat.TextureArray;

/**
 * Custom composite shader
 * that takes into account the type of lens you're using
 * within the game as a player.
 */
class LensCompositeShader extends ScreenShader {
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

    @param var regTexture:Sampler2D;
    @param var uvTexture:Sampler2D;
    @param var infraTexture:Sampler2D;

    /**
     * The type of lens that you're using
     * within the game. Each lens takes up
     * one of the color slots.
     * R = regular
     * G = Infrared
     * B = Ultraviolet
     */
    @param var lensV:Vec3;

    /**
     * The color vector for tinting
     * the game with that specified color.
     */
    function fragment() {
      // 4 UV Flashlight Objects
      var litUVObjects = uvTexture.get(input.uv);
      // 3 - Infrared Flashlight Objects
      var litInfraredObjects = infraTexture.get(input.uv);
      // 2 - Regular Flashlight Objects
      var litRegObjects = regTexture.get(input.uv);
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
        // Handle Platforms in the Light
        if (lensV.r > 0) {
          result += litRegObjects;
        }

        if (lensV.g > 0) {
          result += litInfraredObjects;
        }

        if (lensV.b > 0) {
          result += litUVObjects;
        }
      }

      pixelColor = result;
    }
  }

  public function new(textures:TextureArray) {
    super();
    this.textures = textures;
    this.lensV = new Vector(1, 0, 0);
  }
}