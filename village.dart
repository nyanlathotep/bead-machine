part of gamesystem;

class Village {
  static const int RED_VILLAGE = 0;
  static const int BLUE_VILLAGE = 1;
  static const int GREEN_VILLAGE = 2;
  static const int IVORY_VILLAGE = 3;
  static const int GILDED_TOWN = 4;

  static const int NUM_VILLAGES = 5;

  int currentVillage = RED_VILLAGE;
  int enlightened = 0;
  int timeInIvoryVillage = 0;
  
  Map toJson() {
    Map map = new Map();
    map["currentVillage"] = currentVillage;
    map["timeInIvoryVillage"] = timeInIvoryVillage;
    map["enlightened"] = enlightened;
    return map;
  }

  void load(Map map) {
    currentVillage = map["currentVillage"];
    timeInIvoryVillage = map["timeInIvoryVillage"];
    enlightened = map["enlightened"];
  }
  
  void showCurrent() {
    setVillage(currentVillage);
  }

  void setVillage(int panel) {
    for (int i = 0; i < NUM_VILLAGES; i++) {
      bool active = (panel == i);
      querySelector("#old_man_bead_cost").innerHtml = (calcBeadCost).toString();
      querySelector("#gentleman_tri_cost").innerHtml = (calcTriCost).toString();
      gSetTangible(active, "village_" + i.toString());
    }
    if (panel == GILDED_TOWN) {
      querySelector("#give_btn").text = "Talk";
    } else {
      querySelector("#give_btn").text = "Give";
    }
  }

  int get calcBeadCost => (200.0 * ((this.enlightened * this.enlightened * 5) + 1)).toInt();
  int get calcTriCost => (1000.0 * ((this.enlightened * this.enlightened * 6) + 1)).toInt();

  String clickGive(Player player) {
    if (currentVillage != IVORY_VILLAGE) {
      timeInIvoryVillage = 0;
    }
    switch (currentVillage) {
      case RED_VILLAGE:
        //Give me 600 beads!
        int beadCost = calcBeadCost;
        if (player.resourceInt(Resource.BEADS) >= beadCost) {
          currentVillage++;
          player.decreaseFunction(Resource.BEADS, beadCost.toDouble());
          return "The old man seemed satisfied.";
        }
        break;
      case BLUE_VILLAGE:
        //Pardon me, but might I have 1000 triangles?
        int triCost = calcTriCost;
        if (player.resourceInt(Resource.TRIANGLES) >= triCost) {
          currentVillage++;
          player.decreaseFunction(Resource.TRIANGLES, triCost.toDouble());
          return "The 'gentleman' stuffs all the triangles into his mouth at once.";
        }
        break;
      case GREEN_VILLAGE:
        // Meow, I want 5 free lunches!
        if (player.resourceInt(Resource.FREE_LUNCHES) >= 5) {
          currentVillage++;
          player.decreaseFunction(Resource.FREE_LUNCHES, 5.0);
          return "What? You expect a cat to say thanks?";
        }
        break;
      case IVORY_VILLAGE:
        //Now give me $100,000.
        if (player.resourceInt(Resource.MONEY) >= 100000) {
          player.decreaseFunction(Resource.MONEY, 100000.0);
          timeInIvoryVillage++;
          switch(timeInIvoryVillage) {
            case 1:
              return "Have you ever even owned a cat?";
            case 2:
              return "He's not going to appreciate it.";
            case 3:
              return "Take, take take.";
            case 4:
              return "Cats don't care about you.";
            default:
              currentVillage++;
              return "The cat rubs on your leg affectionately.";
          }
        }
        break;
      case GILDED_TOWN:
        if (Building.FACTORY.isVisible()) {
          if (player.resourceInt(Resource.MONEY) >= 1000000000000) {
            player.decreaseFunction(Resource.MONEY, 1000000000000.0);
            wrapQuests();
            return "Even a Pope's gotta eat.";
          }
        } else {
          if (player.resourceInt(Resource.MONEY) >= 1000000000) {
            player.decreaseFunction(Resource.MONEY, 1000000000.0);
            wrapQuests();
            return "Even a Pope's gotta eat.";
          }
        }
        for (Resource r in Resource.values) {
          if (r != Resource.COLONIES && player.resourceInt(r) > 0) {
            return "You had too much.";
          }
        }
        wrapQuests();
        return "You feel enlightened.";
    }    
    return "You didn't have enough...";
  }

  void wrapQuests() {
    currentVillage = 0;
    gSetVisible(true, "quest_btn");
    enlightened = enlightened + 1;
  }
}