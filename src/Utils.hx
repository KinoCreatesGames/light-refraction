/**
 * Adds the element to the right layer based on their 
 * correct lens layer within the game.
 */

import GameTypes.Lens;

function addToLayerBasedOnLens(obj:h2d.Object, lens:Lens) {
  var layer = switch (lens) {
    case Regular:
      Const.DP_REG;
    case Infrared:
      Const.DP_INFRARED;
    case Ultraviolet:
      Const.DP_UV;
  }

  Game.ME.scroller.add(obj, layer);
}