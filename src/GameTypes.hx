import h3d.Vector;

typedef LvlState = {
  playerPos:Vector,
  reachedCheckpoint:Bool,
  checkpointPos:Vector,
  blockPositions:Array<Vector>
}

typedef LvlSave = {
  playerStart:VectorSave,
  blocks:Array<BlockSave>
}

/**
 * Vector Save Stats
 */
typedef VectorSave = {
  x:Int,
  y:Int,
  z:Int
}

/**
 * Block Save Stats
 */
typedef BlockSave = {
  blockType:BlockType,
  pos:VectorSave
}

/**
 * The different types of block
 * available for the user to use within the
 * game.
 */
enum abstract BlockType(String) from String to String {
  var BlockB:String = 'RegularBlock';
  var BounceB:String = 'BounceBlock';
  var CrackedB:String = 'CrackedBlock';
  var IceB:String = 'IceBlock';
  var MysteryB:String = 'MysteryBlock';
  var StaticB:String = 'StaticBlock';
  var SpikeB:String = 'SpikeBlock';
  var GoalB:String = 'GoalBlock';
  var BlackHoleB:String = 'BlackHoleBlock';
  var HeavyB:String = 'HeavyBlock';
}

enum abstract CollectibleTypes(String) from String to String {
  var BambooR = 'BambooRockets';
  var ShardR = 'Shard';
  var CheckpointR = 'Checkpoint';
  var JLife = 'Life';
  var JetPack = 'JetPack';
}

enum Controllers {
  PauseScreen;
}

/**
 * The type of lens that is being used by the
 * flashlight in the game, which determines
 * the type of light that is being shown within the game.
 */
enum Lens {
  /**
   * Regular Light within the game.
   */
  Regular;

  /**
   * Infrared light within the game.
   * Used with ultraviolet shader.
   */
  Infrared;

  /**
   * Ultraviolet light within the game.
   */
  Ultraviolet;
}

/**
 * MDParsing elements within the game
 * to be used for generating the text elements.
 * Generating texts.
 */
enum MDParse {
  Header(text:String);
  MdHeader(text:String);
  Regular(text:String);
  Blank;
}

/**
 * Player State information
 * used to keep track of information
 * during the game
 * so that we can maintain the information
 * between each level.
 */
typedef PlayerStateT = {
  keys:Int,
  infrared:Bool,
  ultraV:Bool,
  health:Int,
  levelId:Int
}

typedef SettingsStateT = {
  volume:Float,
  lang:String
}

/**
 * An entry in the ghost journal within
 * the game.
 */
typedef GhostEntryT = {
  /**
   * The image used
   * to display the personality
   * of the ghost within the game.
   */
  var imgKey:String;

  /**
   * Name of the ghost
   */
  var name:String;

  /**
   * Description on the ghost
   */
  var desc:String;

  /**
   * Long description of the ghost
   * available once
   * you unlock everything in the game.
   */
  var longDesc:String;

  /**
   * The amount of research
   * done on the current ghost.
   * Determines what part of the
   * UI you can see in the game.
   */
  var researchLvl:Int;
}

/**
 * Structure of the ghost journal.
 */
typedef GhostJournalT = {
  /**
   * List of entries within the  journal.
   */
  var entries:Group<GhostEntryT>;

  var current:GhostEntryT;
}

enum Prop {
  Str(str:String);
  Key(index:Int);
}