package ui;

import ui.cmp.TxtBtn;
import GameTypes.GhostJournalT;
import GameTypes.GhostEntryT;

/**
 * Ghost Journal UI element
 */
class GhostJournal extends h2d.Flow {
  var journal:GhostJournalT;
  var image:h2d.Graphics;
  var cName:h2d.Text;
  var description:h2d.Text;
  var longDesc:h2d.Text;

  public function new(parent:h2d.Object, journal:GhostJournalT) {
    super(parent);
    this.journal = journal;
    createUI();
  }

  public function createUI() {
    this.layout = Horizontal;
    this.horizontalAlign = Middle;

    // Create Detail Area
    var details = new h2d.Flow(this);
    details.layout = Vertical;
    // Create Pics and other elements
    var picArea = new h2d.Flow(details);
    picArea.minHeight = 300;
    // Add other elemnents
    description = 'Test'.mdText(details);
    longDesc = 'Test long desc'.mdText(details);

    // Create List Area
    var list = new h2d.Flow(this);
    list.layout = Vertical;
    list.overflow = h2d.Flow.FlowOverflow.Scroll;
    for (entry in journal.entries) {
      var btn = new TxtBtn(entry.name, list);
      btn.onClick = (event) -> {
        #if debug
        trace('Add entry');
        #end
        journal.current = entry;
        renderChanges();
      };
    }
  }

  public function renderChanges() {
    // TODO: Add Image processing
    cName.text = journal.current.name;
    description.text = journal.current.desc;
    longDesc.text = journal.current.longDesc;
  }
}