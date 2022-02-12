package ext;

import GameTypes.Prop;
import GameTypes.GhostJournalT;

// Ghost Journal Tools
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