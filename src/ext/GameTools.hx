package ext;

import GameTypes.GhostEntryT;
import GameTypes.Prop;
import GameTypes.GhostJournalT;

// Ghost Journal Tools
inline function createEntry(name:String = 'Test', img:String = '',
    desc:String = 'Description',
    lDesc:String = 'Long Description'):GhostEntryT {
  return {
    name: name,
    desc: desc,
    longDesc: lDesc,
    researchLvl: 0,
    imgKey: img
  }
}

inline function updateResearchLvl(journal:GhostJournalT, amount:Int,
    prop:Prop) {
  var entry = getEntry(journal, prop);
  entry.researchLvl = amount;
  return journal;
}

function getEntry(journal:GhostJournalT, prop:Prop) {
  return switch (prop) {
    case Str(str):
      journal.entries.filter((el -> el.name.toLowerCase() == str.toLowerCase()))
        .first();
    case Key(index):
      journal.entries.get(index);
  }
}