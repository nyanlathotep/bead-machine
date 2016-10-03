part of gamesystem;

class Quest {
  static const int BOT_QUEST_01 = 0;
  static const int OLD_MAN_QUEST_01 = 1;
  static const int OLD_MAN_QUEST_02 = 2;
  static const int OLD_MAN_QUEST_03 = 3;
  static const int CAT_QUEST_01 = 4;
  static const int CAT_QUEST_02 = 5;
  static const int POPE_QUEST_01 = 6;
  static const int BOT_QUEST_02 = 7;
  static const int BOT_QUEST_03 = 8;
  static const int GENTLEMAN_QUEST_01 = 9;
  static const int GENTLEMAN_QUEST_02 = 10;
  static const int GENTLEMAN_QUEST_03 = 11;
  static const int SHOP = 12;

  static const int TWO_BILLION = 2000000000;

  int currentQuest = BOT_QUEST_01;
  QuestBot questBot = new QuestBot();
  bool schoolEnabled = true;

  Quest() {
    Building.initBuildings();
  }

  Map toJson() {
    var vendAssembly = querySelector("#vend_assembly");
    Map map = new Map();
    map["currentQuest"] = currentQuest;
    map["schoolEnabled"] = schoolEnabled;
    map["assemblyMode"] = vendAssembly.checked;
    return map;
  }

  void load(Map map) {
    var vendAssembly = querySelector("#vend_assembly");
    currentQuest = map["currentQuest"];
    schoolEnabled = !(map["schoolEnabled"] == false);
    if (!(map["assemblyMode"] == false)) {
      vendAssembly.checked = true;
    } else {
      vendAssembly.checked = true;
    }
    
    // if null, default to true
    if (currentQuest > BOT_QUEST_01) {
      gSetVisible(true, "quest_stats");
    }
    if (currentQuest >= BOT_QUEST_02) {
      gSetVisible(true, "hovel_btn");
    }
    if (currentQuest >= BOT_QUEST_03) {
      Building.DORM.setVisible(true);
    }
    if (currentQuest >= GENTLEMAN_QUEST_01) {
      Building.TOOL_FACTORY.setVisible(true);
    }
    if (currentQuest >= GENTLEMAN_QUEST_02) {
      Building.FARM.setVisible(true);
      Building.FIELD_01.setVisible(true);
      Building.FIELD_02.setVisible(true);
    }
    if (currentQuest >= GENTLEMAN_QUEST_03) {
      Building.STORE.setVisible(true);      
    }

    setSchoolEnabled(schoolEnabled);
  }

  void setQuestNarration(String n) {
    var narration = querySelector("#quest_narration");
    final NodeValidatorBuilder _htmlValidator=new NodeValidatorBuilder.common()
      ..allowElement('span', attributes: ['style']);
    narration.setInnerHtml(n, validator: _htmlValidator);
  }

  void continueQuest(Player p, Shop shop) {
    if (currentQuest >= GENTLEMAN_QUEST_03) {
      shop.toggle();
      currentQuest = SHOP;
      showQuest(p);
      return;
    }
    gSetVisible(true, "quest_stats");
    switch (currentQuest) {
      case BOT_QUEST_02:
        p.resources[Resource.TRIANGLES.value] -= 300000;
        break;
      case BOT_QUEST_03:
        p.resources[Resource.BEADS.value] -= 2000000;
        break;
    }
    currentQuest++;
    gSetTangible(false, "continue_quest_btn");
    showQuest(p);
  }

  void showQuest(Player p) {
    final String gentleman = "     (@)\n" "      │\n" "     / \\\n";

    final String oldMan = "     [Ö]\n" + "      │\n" + "     / \\";

    final String pope =
        """
               /
          /\\   |
         /  \\  |/
        |    | |>
        \\____/ |
        ( .. ) |
        /\\__/\\ |
       /\\ qp /\\|
      /  |  |  |
     /|  |db| /\\`\\
     | \\ |  | \\|_|
     \\  \\|qp|  |
      \\__/  |  |
      |/||db|  |
      |  |  |  |
""";

    if (currentQuest > OLD_MAN_QUEST_01) {
      gSetVisible(true, "colony");
    }

    switch (currentQuest) {
      case BOT_QUEST_01:
        this.currentQuest = OLD_MAN_QUEST_01;
        setQuestNarration("You begin walking down the long, dusty road, " +
            "leaving your home province for the first time.<br><br>" +
            "A robot appears before you.");
        questBot.show("Bzzzzt. WAIT! You're going to need a bigger machine " +
            "before you go that way!");
        break;
      case OLD_MAN_QUEST_01:
        gSetTangible(true, "continue_quest_btn");
        setQuestNarration("You reach the edge of the province.<br>" +
            "What you see amazes you.  Desolation, as far as the eye " + "can see.<br><br>"
            + "The Crusty Old Man is here:<br><pre>" + oldMan + "</pre><br>" +
            "Ours was the only province to survive the war, and I see that " +
            "you have mastered the machine.<br><br>" +
            "You are the one who can help us to <b>rebuild</b>.<br><br>");
        questBot.hide();
        break;
      case OLD_MAN_QUEST_02:
        setQuestNarration("<pre>Fund a School:\n" + "  Max Students:     25\n" +
            "  Upkeep:           \$" + (Building.SCHOOL.cost[0] ~/ 1000).toString() + "k" +
            "</pre><br>" + "The Crusty Old Man is here:<br><pre>" + oldMan + "</pre><br>" +
            "You can't go rebuilding the wasteland on your own, you dang fool! " +
            "Build a school!  And if'n you want to keep the school open, " +
            "we'll need a steady income of \$" + (Building.SCHOOL.cost[0] ~/ 1000).toString(
            ) + "k." + "<br><br>If you don't have enough money, you lose students.<p>");
        break;
      case OLD_MAN_QUEST_03:
        setQuestNarration("<pre>Make 100 Vending Machines:\n" +
            "  Max Workers:     25\n" + "  Machine Cost:    B" + (Building.FACTORY.cost[0]
            ~/ 1000).toString() + "k" + "</pre><br>" +
            "The Crusty Old Man is here:<br><pre>" + oldMan + "</pre><br>" +
            "After they get some learnin', students can go work in the old abandoned vending machine factory. "
            +
            "It'll be good to start making those again, seein' as how we only got the one right now."
            + "<p>");
        break;
      case CAT_QUEST_01:
        setQuestNarration("<pre>Make a coil</pre><pre>" + Cat.ART +
            "</pre>I figured that you'd rather have one of those " +
            "new models of Vending Machines that you're making over at the factory, instead of "
            +
            "that ancient model we have in the center of town.<br><br>These new fangled things "
            +
            "take coils, but I've rigged it up to give you your first part for free.<br><br>"
            + "*begins licking paws and washing ears*");
        break;
      case CAT_QUEST_02:
        String q = "<pre>Start 3 colonies.</pre>Colonies require:<ul>";
        for (int i = 0; i < Building.DEPOT.cost.length; i++) {
          q += "<li>" + Building.DEPOT.costType[i].abbrv +
              Building.DEPOT.cost[i].toString();
        }
        q += "</ul>";
        q += "<pre>" + Cat.ART + "</pre>" +
            "It's time to start founding new colonies.<p>" +
            "Caravans of settlers loaded with supplies depart from the depot.  They will need "
            +
            "vending machines, students, workers and a supply of coils to get them started out "
            + "there in the barren wastes.<p>";
        setQuestNarration(q);
        break;
      case POPE_QUEST_01:
        setQuestNarration("<pre>Gain 5 enlightenment</pre><pre>" + pope +
            "</pre>While exploring the unsettled areas of the ruins, " +
            "you find a run down hovel.  When you approach the door, the Pope comes out.  This "
            + "must be where he's living.<br><br>He walks out onto the sagging porch and " +
            "waves to you as the screen door bangs closed behind him.<br><br>'If you were more enlightened, "
            + "I could teach you the secrets of the wastes.'" + "");
        break;
      case BOT_QUEST_02:
        gSetVisible(true, "hovel_btn");
        setQuestNarration("The Pope takes you to his robot.");
        questBot.show(
            "If I had a stockpile of 300k triangles, I could rebuild that dorms, then you "
            "you could have twice the students for the same upkeep costs.");
        break;
      case BOT_QUEST_03:
        Building.DORM.setVisible(true);
        questBot.show(
            "If I had a stockpile of 2M beads, I could rebuild that tool factory, then you "
            "your factory workers would be twice as productive.");
        break;
      case GENTLEMAN_QUEST_01:
        questBot.hide();
        Building.TOOL_FACTORY.setVisible(true);
        setQuestNarration("Produce: 3M Triangles<br><pre>" + gentleman +
            "</pre>The country gentleman appears by your "
            "side as you look out over the valley where your now thriving colony buzzes with"
            "activity.<p>\"I'm impressed,\" he grudgingly admits. \"But if your population "
            "continues to expand at this rate, we're going to run out of food.\"<p>"
            "\"Bring me three million triangles, and I can start a farm in the north plot that "
            "could feed us for generations.\"");
        break;
      case GENTLEMAN_QUEST_02:
        String dollar = p.resourceInt(Resource.MONEY) >= TWO_BILLION ? "green" : "red";
        String tris = p.resourceInt(Resource.TRIANGLES) >= TWO_BILLION ? "green" : "red";
        String beads = p.resourceInt(Resource.BEADS) >= TWO_BILLION ? "green" : "red";
        setQuestNarration("Produce: <span style='color:$dollar;'>\$2B</span>, "
            + "<span style='color:$tris'>2B Triangles</span>, <span style='color:$beads'>"
            + "2B Beads</span><br><br>Time to open a store...<pre>"
            + gentleman + "</pre>Such a thing needs capital.<p>");
        Building.FARM.setVisible(true);
        Building.FIELD_01.setVisible(true);
        Building.FIELD_02.setVisible(true);
        break;
      case GENTLEMAN_QUEST_03:
        Building.STORE.setVisible(true);
        setQuestNarration("The 'gentleman' shoves as many of the triangles as he can into his mouth. "
            + "He stuffs as many as he can carry into his pockets.  As he walks away down the dusty road, "
            + "he says something that sounds like, 'Thanks, chump' but it's hard to tell with his "
            + "mouth so full.  A few days later, a new store opens on the western end of town.");
        gSetTangible(true, "continue_quest_btn");
        var btn = querySelector("#continue_quest_btn");
        btn.value = "Shop";
        break;
      case SHOP:
        setQuestNarration("Life continues peacefully.<p>");
        gSetTangible(true, "continue_quest_btn");
        var btn = querySelector("#continue_quest_btn");
        btn.value = "Shop";
    }
  }

  // Returns a list of pairs (i.e. lists) of (Resource+Amount)
  void process(Player p, Village v) {
    // Consider having a map of buildings to Quest stages instead of manually coding that.
    switch (currentQuest) {
      case OLD_MAN_QUEST_02:
        {
          processBuilding(Building.SCHOOL, p);
          if (p.resources[Resource.STUDENTS.value] == Resource.STUDENTS.max) {
            showContinueButton();
          }
        }
        break;
      case OLD_MAN_QUEST_03:
        {
          processBuilding(Building.SCHOOL, p);
          processBuilding(Building.FACTORY, p);
          if (p.resources[Resource.VENDING_MACHINES.value] >= 100) {
            showContinueButton();
          }
        }
        break;
      case CAT_QUEST_01:
        {
          processBuilding(Building.SCHOOL, p);
          processBuilding(Building.FACTORY, p);
          if (p.resources[Resource.COILS.value] > 1) {
            showContinueButton();
          }
        }
        break;
      case CAT_QUEST_02:
        {
          processBuilding(Building.SCHOOL, p);
          processBuilding(Building.FACTORY, p);
          processBuilding(Building.DEPOT, p);
          if (p.resources[Resource.COLONIES.value] >= 3) {
            showContinueButton();
          }
        }
        break;
      case POPE_QUEST_01:
        processBuilding(Building.SCHOOL, p);
        processBuilding(Building.FACTORY, p);
        processBuilding(Building.DEPOT, p);
        processBuilding(Building.HOVEL, p);
        if (v.enlightened >= 5) {
          showContinueButton();
        }
        break;
      case BOT_QUEST_02:
        processBuilding(Building.SCHOOL, p);
        processBuilding(Building.FACTORY, p);
        processBuilding(Building.DEPOT, p);
        processBuilding(Building.HOVEL, p);
        showContinueButton(p.resources[Resource.TRIANGLES.value] >= 300000);
        break;
      case BOT_QUEST_03:
        processBuilding(Building.SCHOOL, p);
        processBuilding(Building.FACTORY, p);
        processBuilding(Building.DEPOT, p);
        processBuilding(Building.HOVEL, p);
        showContinueButton(p.resources[Resource.BEADS.value] >= 2000000);
        break;
      case GENTLEMAN_QUEST_01:
        debugProcessAllBuildings(p);
        showContinueButton(p.resources[Resource.TRIANGLES.value] >= 3000000);
        break;
      case GENTLEMAN_QUEST_02:
        debugProcessAllBuildings(p);
        showQuest(p);
        bool ready = p.resourceInt(Resource.MONEY) >= TWO_BILLION &&
             p.resourceInt(Resource.TRIANGLES) >= TWO_BILLION  &&
             p.resourceInt(Resource.BEADS) >= TWO_BILLION;
        showContinueButton(ready);        
        break;
      default:
        if (currentQuest > OLD_MAN_QUEST_01) {
          debugProcessAllBuildings(p);
        }
    }
  }

  void setSchoolEnabled(bool e) {
    schoolEnabled = e;
    var btn = querySelector("#school_state_btn");
    btn.value = "School: " + (schoolEnabled ? "ON" : "OFF");
  }

  void showContinueButton([bool tangible = true]) {
    gSetTangible(tangible, "continue_quest_btn");
    if (tangible) {
      var btn = querySelector("#continue_quest_btn");
      btn.value = "Continue";
    }
  }

  void debugProcessAllBuildings(Player p) {
    for (Building b in Building.values) {
      processBuilding(b, p);
    }
  }

  void processBuilding(Building b, Player p) {
    if (b == Building.SCHOOL && !schoolEnabled) {
      if (p.resourceInt(Resource.STUDENTS) > 0) {
        if (Player.clampedStudents) {
          Player.clampedStudents = false;
        } else {
          p.resources[Resource.STUDENTS.value]--;
        }
      }
      return;
    }
    if (b == Building.FACTORY && currentQuest >= OLD_MAN_QUEST_03) {
      b.setVisible(true);
    }
    if (b == Building.HOVEL) {
      if (this.currentQuest >= POPE_QUEST_01) {
        b.setVisible(true);
      }
      return;
    }
    List<ResourceResult> retVal = new List();
    b.process(p.resources, retVal);
    for (ResourceResult x in retVal) {
      p.increaseFunction(x.r, x.amt);
    }
  }

  void setBuildingVisible(int bld, bool arg1) {
    Building.values[bld].setVisible(arg1);
    return;
  }
}
