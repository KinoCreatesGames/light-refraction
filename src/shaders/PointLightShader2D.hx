package shaders;

/**
 * 2D PointLight Shader
 * that allows you to create a spotlight effect
 * within your game similar
 * to the Pokemon franchise games in the caves.
 */
class PointLightShader2D extends hxsl.Shader {
  static var SRC = {
    @:import h3d.shader.Base2d; // Necessary for base 2D Shaders

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

    @param var sTime:Float;
    function fragment() {
      // Room Color Without Lights
      // var texColor = texture.get(input.uv);
      // Room color with the lights on
      //   var lights = texs.get(vec3(input.uv, 0));
      // Center  of the radial circle
      var uv = input.uv;
      var movingCenter = vec2(pos.x / widthHeight.x, pos.y / widthHeight.y);
      // Screen center
      var center = vec2(.5, .5);
      // Correct for the resolution aspect ratio
      // We scale all elements on the x axis to have them stretch
      // To meet the Y coordinates
      var resolutionCorrect = vec2(widthHeight.x / widthHeight.y, 1.);
      // Percent away from the center
      var pct = distance(input.uv, movingCenter);
      // Smoothing
      var str = 1 - (smoothstep(0.2, radius + smoothEdges, pct));

      //   var tmp = texColor;
      //   texColor *= ((str));
      //   Smooth Edges
      // pixelColor = pixelColor;
      var light = vec4(1, 1, 1, 1);
      // light *= cos(sTime);

      var cl = vec4(color.rgb, 1);
      cl = mix(light, cl, .7);
      // cl = light * cl;
      if (pct > radius) {
        var result = clamp(1 - pct, .1, 1);
        // Tint instead
        // cl.b *= result * (1 - str);
        // cl.g *= result;
      }
      // cl =
      // cl.a *= (1 - pct) * .5;
      // cl *= str;
      cl.a *= 1 - pct;
      // cl.a *= (str * .3);
      // cl.r = uv.x;
      // cl.b = uv.y;
      // cl.g = 0;
      // cl *= 1.5;
      pixelColor = cl;
      // pixelColor = texColor * str;
    }
  }

  public function new(radius:Float = .45, smoothEdge:Float = 0.02,
      strength:Float = .3) {
    super();
    this.radius = radius;
    this.smoothEdges = smoothEdge;
    this.strength = strength;
    this.sTime = 0;
  }
}