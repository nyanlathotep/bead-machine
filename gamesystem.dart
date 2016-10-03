library gamesystem;

import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:convert';
import 'dart:math';

import 'resources.dart';
import 'gameutils.dart';

part 'achievements.dart';
part 'buildings.dart';
part 'cat.dart';
part 'player.dart';
part 'parts.dart';
part 'machine.dart';
part 'questrobot.dart';
part 'quest.dart';
part 'shop.dart';
part 'vending.dart';
part 'village.dart';

bool debugModeEnabled = false;

class ResourceResult {
  Resource r;
  double amt;
  ResourceResult(this.r, this.amt);
}

Map<String, String> getUriParams(String uriSearch) {
  if (uriSearch != '') {
    final List<String> paramValuePairs = uriSearch.substring(1).split('&');

    var paramMapping = new HashMap<String, String>();
    paramValuePairs.forEach((e) {
      if (e.contains('=')) {
        final paramValue = e.split('=');
        paramMapping[paramValue[0]] = paramValue[1];
      } else {
        paramMapping[e] = '';
      }
    });
    return paramMapping;
  }
  return null;
}

class GameSystem {
  Player player = new Player();
  Machine machine = new Machine();
  VendingMachine vending = new VendingMachine();
  Cat cat = new Cat();
  Village village = new Village();
  Quest quest = new Quest();
  Shop shop;
  bool travelVisible = false;
  bool buttonBarVisible = false;
  String saveKey = null;
  int curPanel = VENDING_PANEL;

  static const int NUM_MAIN_PANELS = 5;
  static const int VENDING_PANEL = 0;
  static const int MACHINE_PANEL = 1;
  static const int TRAVEL_PANEL = 2;
  static const int QUEST_PANEL = 3;
  static const int ACHIEVEMENT_PANEL = 4;
  
  GameSystem() {
    shop = new Shop(player, machine, vending);
    bindButtons();
    machine.show();
    vending.show();
    cat.show();

    gSetVisible(true, "free_lunch_btn");

    if (Machine.infinite) {
      setTravelVisible(true);
      setButtonBarVisible(true);
    }
    Map m = getUriParams(window.location.search);
    bool loading = false;
    if (m != null) {
      if (m["key"] != null) {
        makeLoadRequest(m["key"]);
        loading = true;
      }
    }
    if (!loading) {
      debugSetup();
    }
    localLoad();
  }
  
  void debugSetup() {
    if (!debugModeEnabled) {
      return;
    }
    gSetTangible(true, "clear_resources_btn");
    vending.setVisible(true);
    player.increaseAmount = 30.0;
    player.resources[0] += 5000;
    gSetVisible(true, "quest_btn");
    //village.enlightened = 1;
    village.currentVillage = Village.GILDED_TOWN;
    querySelector("#modeShade").classes.remove("hiddenShade");
  }

  void makeLoadRequest(String key) {
    HttpRequest.getString("https://victoryquester.appspot.com/?action=load&key=${Uri.encodeComponent(key)}").then((response) {
      print(response);
      saveKey = key;
      load(response);
      // For DEBUGGING:
      debugSetup();
    });
  }

  void setTravelVisible(bool value) {
    travelVisible = value;
    gSetVisible(value, "travel_container");
  }
  
  void setButtonBarVisible(bool value) {
    buttonBarVisible = value;
    gSetVisible(true, "button_bar");
  }
  
  void gainFunc(Timer t) {
    updateMachine();
    updateVending();
    updateQuest();
    updateResources();
    updateAchievements();
    updateShop();
  }
  
  updateShop() {
    shop.update();
  }

  void updateAchievements() {
    if (quest.currentQuest > Quest.POPE_QUEST_01) {
      Achievements.doChecks(player, village, machine);
    }
  }
  
  void updateResources() {
    player.showResources(village);
    if (player.resourceInt(Resource.MONEY) >= 50) {
      vending.setVisible(true);
    }
    if (player.resourceInt(Resource.BEADS) > 0) {
      cat.setVisible(true);
      if (!travelVisible) {
        setTravelVisible(true);
        setTravelMessage("You notice a path you hadn't seen before.");
      }
    }
    var btn = querySelector("#salesman_btn");
    if (player.resources[Resource.VENDING_MACHINES.value] < 1 ||
        player.resources[Resource.FACTORY_WORKERS.value] < 1) {
      btn.disabled = true;
    } else {
      btn.disabled = false;
    }
    if (quest.currentQuest >= Quest.OLD_MAN_QUEST_03) {
      gSetVisible(true, "salesman_btn");
    }
  }

  void updateQuest() {
    quest.process(player, village);
  }

  void updateVending() {
    if (curPanel == VENDING_PANEL) {
      if (quest.currentQuest >= Quest.CAT_QUEST_01 && !vending.colorCycle) {
        vending.upgrade();
      }
      vending.show();
    }
  }

  void updateMachine() {
    var result = machine.process(player.resources, Resource.MONEY, player.increaseAmount);
    for (List x in result) {
      player.increaseFunction(x[0], x[1]);
    }
  }

  // **** EVENT BINDINGS ****
  void clickVend(MouseEvent event) {
    double vendCost = vending.cost;
    if (player.resourceInt(vending.currency) >= vendCost) {
      player.decreaseFunction(vending.currency, vendCost);
      List<Part> items = vending.vend();
      player.addParts(items);
      // machine.clear();
      machine.initList(player.getParts());
      shop.show();
      setButtonBarVisible(true);
    } else {
      vending.failToVend();
    }
  }

  void clickClearMachineButton(MouseEvent event) {
    machine.clear();
  }
  
  void clickSalesmanButton(MouseEvent event) {
    player.increaseFunction(Resource.FACTORY_WORKERS, -1.0);
    player.increaseFunction(Resource.VENDING_MACHINES, -5.0);
    if (player.resources[Resource.VENDING_MACHINES.value] < 1 ||
        player.resources[Resource.FACTORY_WORKERS.value] < 1) {
      var btn = querySelector("#salesman_btn");
      btn.disabled = true;
    }
  }
  
  void clickFreeLunchButton(MouseEvent event) {
    player.increaseFunction(Resource.FREE_LUNCHES, 1.0);
    player.showLunches();
  }

  void clickFreeMoneyButton(MouseEvent event) {
    player.increaseFunction(Resource.MONEY, 10.0);
    player.showMoney();
  }
  
  void clickVersion(MouseEvent event) {
    var version = querySelector("#revision_history");
    if (version.classes.contains("invisible")) {
      version.classes.remove("invisible");    
    } else {
      version.classes.add("invisible");    
    }
  }
  
  void clickHovelButton(MouseEvent event) {
    setMainPanel(ACHIEVEMENT_PANEL);
    querySelector("#main_btn").classes.remove("active");
    querySelector("#hovel_btn").classes.add("active");
    querySelector("#machine_btn").classes.remove("active");
    querySelector("#quest_btn").classes.remove("active");
    Achievements.render();
  }
  
  void clickQuestButton(MouseEvent event) {
    setMainPanel(QUEST_PANEL);
    querySelector("#main_btn").classes.remove("active");
    querySelector("#machine_btn").classes.remove("active");
    querySelector("#hovel_btn").classes.remove("active");
    querySelector("#quest_btn").classes.add("active");
    shop.showPlayerInventory();
    if (quest.currentQuest == Quest.BOT_QUEST_01 ) {
      expandGridBeforeQuest();
    }
    quest.showQuest(player);
  }
  
  void expandGridBeforeQuest() {
    machine.clear();
    Machine.GRID_X = Machine.MAX_GRID_X;
    Machine.GRID_Y = Machine.MAX_GRID_Y;
    machine.createGrid();
  }
  
  void clickMainButton(MouseEvent event) {
    setMainPanel(VENDING_PANEL);
    querySelector("#main_btn").classes.add("active");
    querySelector("#hovel_btn").classes.remove("active");
    querySelector("#machine_btn").classes.remove("active");
    querySelector("#quest_btn").classes.remove("active");
    if (machine.brokenArrow) {
      cat.talk("Red arrows on your machine means you're throwing something away.  Change or remove the part it's pointing to in order to fix it....  Er.. I mean... meow.");
    } else if (village.enlightened == 0 && village.currentVillage == Village.RED_VILLAGE &&
          player.resources[Resource.BEADS.value] == 0) {
      cat.setVisible(true);
      cat.talk("Hoppers take from your current inventory and output it into the machine. "
          + "Anything being output straight into an empty square gets added to your inventory.");
    } else if (quest.currentQuest == Quest.SHOP) {
      cat.talk("'Selling' in the shop actually just reduces the price of the next item you buy.  I'm not sure that robot really understands how stores work..... mew");
    } else {
      if (cat.visible) {
        cat.talk("");
      }
    }
  }
  
  void clickSaveButton(MouseEvent event) {
    String saveVal = JSON.encode(this);
    //http://victoryquester.appspot.com/?action=load&key=ahBzfnZpY3RvcnlxdWVzdGVycg4LEghTYXZlR2FtZRgBDA
    //http://victoryquester.appspot.com/?action=save&code=blah
    makeSaveRequest(saveVal);
    // load(""" {"buttonBarVisible":true,"travelVisible":true,"cat":{"visible":true,"statementCount":1},"village":{"currentVillage":0,"timeInIvoryVillage":0},"player":{"resources":[138,0,12,0],"parts":[{"index":6},{"index":9},{"index":9},{"index":0}]},"vending":{"cost":112,"visible":true,"vendCount":2,"increment":1.5},"machine":{"parts":[null,null,null,null,null,null,{"index":0},{"index":9},{"index":9},{"index":6},null,null,null,null,null,null,null,null,null,null,null,null,null,null,null]}} """);
  }

  void makeSaveRequest(String saveVal) {
    String serverUrl = "https://victoryquester.appspot.com";

    Map<String, String> params = new HashMap<String, String>();
    params["action"] = "save";
    params["code"] = saveVal;
    if (saveKey != null) {
      params["key"] = saveKey;
    }
    HttpRequest.postFormData(serverUrl, params)
      .then((response) {
        Element resp = querySelector("#save_response");
        saveKey = response.response.toString();
        resp.innerHtml = "click <a href='?key=${Uri.encodeComponent(saveKey)}'>here</a> to load.";
      })
      .catchError((e) {
        // handle error
        Element resp = querySelector("#save_response");
        resp.innerHtml = "Error: " + e.toString();
      });
  }

  Map toJson() {
    Map map = new Map();
    map["player"] = player;
    map["cat"] = cat;
    map["village"] = village;
    map["vending"] = vending;
    map["machine"] = machine;
    map["buttonBarVisible"] = buttonBarVisible;
    map["travelVisible"] = travelVisible;
    map["quest"] = quest;
    map["achievements"] = Achievements.toJson();
    return map;
  }

  void load(String state) {
    Map map = JSON.decode(state);
    setButtonBarVisible(map["buttonBarVisible"]);
    setTravelVisible(map["travelVisible"]);
    cat.load(map["cat"]);
    village.load(map["village"]);
    player.load(map["player"]);
    vending.load(map["vending"]);
    machine.initList(player.parts);
    machine.load(map["machine"]);
    quest.load(map["quest"]);
    Achievements.load(map["achievements"]);
    gSetVisible(village.enlightened != 0, "quest_btn");
  }

  void localLoad() {
    String save = window.localStorage['save'];
    if (save != null) {
      load(save);
    }
  }

  void localSave() {
    String save = JSON.encode(this);
    window.localStorage['save'] = save;
  }

  void clickLocalSaveButton(MouseEvent event) {
    localSave();
  }

  void clickLocalLoadButton(MouseEvent event) {
    localLoad();
  }

  void clickMachineButton(MouseEvent event) {
    setMainPanel(MACHINE_PANEL);
    querySelector("#main_btn").classes.remove("active");
    querySelector("#quest_btn").classes.remove("active");
    querySelector("#machine_btn").classes.add("active");
    querySelector("#hovel_btn").classes.remove("active");
  }
  
  void clickGoButton(MouseEvent event) {
    setMainPanel(TRAVEL_PANEL);    
    setTravelMessage("");
    village.showCurrent();
  }

  void clickContinueQuest() {
    quest.continueQuest(player, shop);
  }
  
  void clickGiveToVillager() {
    String message = village.clickGive(player);
    setTravelMessage(message);
    setMainPanel(VENDING_PANEL);
  }
  
  void bindButtons() {
    querySelector("#modeShade input:first-child").onChange.listen(changeMode1);
    querySelector("#modeShade input:nth-child(2)").onChange.listen(changeMode2);
    querySelector("#save_btn").onClick.listen(clickSaveButton);
    querySelector("#local_save_btn").onClick.listen(clickLocalSaveButton);
    querySelector("#local_load_btn").onClick.listen(clickLocalLoadButton);
    querySelector("#vend_btn").onClick.listen(clickVend);
    querySelector("#free_money_btn").onClick.listen(clickFreeMoneyButton);
    querySelector("#free_lunch_btn").onClick.listen(clickFreeLunchButton);
    querySelector("#salesman_btn").onClick.listen(clickSalesmanButton);
    querySelector("#main_btn").onClick.listen(clickMainButton);
    querySelector("#quest_btn").onClick.listen(clickQuestButton);
    querySelector("#hovel_btn").onClick.listen(clickHovelButton);
    querySelector("#version").onClick.listen(clickVersion);
    querySelector("#machine_btn").onClick.listen(clickMachineButton);
    querySelector("#clear_btn").onClick.listen(clickClearMachineButton);
    querySelector("#go_btn").onClick.listen(clickGoButton);
    querySelector("#go_back_btn").onClick.listen((e) => setMainPanel(VENDING_PANEL));
    querySelector("#school_state_btn").onClick.listen((e) => clickSchoolButton());
    querySelector("#give_btn").onClick.listen((e) => clickGiveToVillager());
    querySelector("#continue_quest_btn").onClick.listen((e) => clickContinueQuest());
    querySelector("#clear_resources_btn").onClick.listen((e) => clickClearButton());
  }
  
  void clickSchoolButton() {
    quest.setSchoolEnabled(!quest.schoolEnabled);
  }
  
  void clickClearButton() {
    for (Resource r in Resource.values) {
      player.resources[r.value] = 0.0;
    }
    vending.cost = 1.0;
  }

  // **** DISPLAY FUNCTIONS *****  
  void setTravelMessage(String msg) {
    querySelector("#travel_msg").text = msg;
  }

  void setMainPanel(int panel) {
    curPanel = panel;
    if (panel == VENDING_PANEL) {
      vending.show();
    }
    for (int i = 0; i < NUM_MAIN_PANELS; i++) {
      bool active = (panel == i);
      gSetVisible(active, "main_0" + i.toString());
      gSetTangible(active, "main_0" + i.toString());
    }
  }
  
  void changeMode1(Event event) {
    Machine.infinite = false;
    if (quest.currentQuest == Quest.BOT_QUEST_01) {
      Machine.GRID_X = 5;
      Machine.GRID_Y = 5;
    }
    machine = new Machine();
    machine.show();
    machine.initList(player.getParts());
  }
  void changeMode2(Event event) {
    Machine.infinite = true;
    Machine.GRID_X = 8;
    Machine.GRID_Y = 8;
    machine = new Machine();
    machine.show();
    setButtonBarVisible(true);
  }
}
