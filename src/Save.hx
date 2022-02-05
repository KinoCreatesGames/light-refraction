import en.Player;

/**
 * Saves player information to the game state.
 * @param game 
 * @param player 
 */
function setPlayerState(game:Game, player:Player) {
  game.playerState = {
    keys: player.keys,
    infrared: player.infraredUnlocked,
    ultraV: player.ultraVioletUnlocked,
    health: player.health,
    levelId: player.level.data.uid
  }
}

/**
 * Loads the player information from the game state.
 * @param game 
 * @param player 
 */
function getPlayerState(game:Game, player:Player) {
  var data = game.playerState;
  if (data != null) {
    player.keys = data.keys;
    player.infraredUnlocked = data.infrared;
    player.ultraVioletUnlocked = data.ultraV;
    player.health = data.health;
    // Add level Id information later for saving purposes
  }
}