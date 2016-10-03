part of gamesystem;

class QuestBot {
  bool tangible = false;

  void setTangible(bool v) {
    tangible = v;
    gSetTangible(v, "quest_bot");
  }

  void hide() {
    setTangible(false);
  }
  
  void show(String s) {
    var speech = querySelector("#quest_bot_speech");
    speech.innerHtml = s;
    setTangible(true);
  }
}

/*
 * school requires x traingles / per turn?
 * army needs x beads / per turn
 * power plant needs x money / per turn
 * 
 */
