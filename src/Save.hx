import hxd.Event;
import dn.data.SavedData;
import en.Player;

/**
 * Save game constants within the game.
 */
enum abstract SaveT(String) from String to String {
  var PLAYER_STATE = 'PlayerState';
  var EVENT_LIST = 'EventList';
}

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

/**
 * Saves the player state to the 
 * save data within the game.
 * @param game 
 * @param player 
 */
function savePlayerState(game:Game, player:Player) {
  var data = game.playerState;

  SavedData.save(PLAYER_STATE, {
    keys: player.keys,
    infrared: player.infraredUnlocked,
    ultraV: player.ultraVioletUnlocked,
    health: player.health,
    levelId: player.level.data.uid
  });
}

/**
 * Loads the player state from the save data 
 * within the game.
 * @param game 
 * @param player 
 */
function loadPlayerState(game:Game, player:Player) {
  if (SavedData.exists(PLAYER_STATE)) {
    var data = SavedData.load(PLAYER_STATE, {
      keys: 0,
      infrared: false,
      ultraV: false,
      health: 3,
      levelId: ''
    });
    return data;
  }
  return null;
}

/**
 * Saves an event to the save data
 * using the event name as the key.
 * If the event exists within the list
 * of the game's keys, we will not 
 * process that event again within the game
 * until the save data is cleared.
 * @param eventName 
 */
function saveEvent(game:Game, eventName:String) {
  if (SavedData.exists(EVENT_LIST)) {
    var eventList = SavedData.load(EVENT_LIST, {
      events: []
    });
    eventList.events.push(eventName);
    SavedData.save(EVENT_LIST, {
      events: eventList.events
    });
  } else {
    SavedData.save(EVENT_LIST, {
      events: [eventName]
    });
  }
  #if debug
  trace('Saved  event ${eventName} within the game');
  #end
}

/**
 * Checks if an event exists within the game's 
 * data. Returns true or false otherwise.
 * @param eventName 
 */
function eventExists(game:Game, eventName:String) {
  if (SavedData.exists(EVENT_LIST)) {
    var eventList = SavedData.load(EVENT_LIST, {
      events: []
    });
    return eventList.events.contains(eventName);
  } else {
    return false;
  }
}

// Data Clears

/**
 * Clears all the game data for any new games
 * within the game.
 */
function clearNewGameData(game:Game) {
  SavedData.delete(PLAYER_STATE);
  SavedData.delete(EVENT_LIST);
  #if debug
  trace('Clear the game data.');
  #end
}