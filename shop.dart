part of gamesystem;

class Shop {
  bool visible = false;
  Player p;
  Machine m;
  VendingMachine v;

  var lastClick = null;
  bool storeItem = null;

  /*
   50C = 1B (1/50 C)
   2B = $1 (1/100 C)
   $2 = 1T (1/200 C)
   */
  Resource storeCurrency = Resource.COILS;

  double getCurrentCost() {
    double vendValue = v.cost;
    switch (storeCurrency) {
      case Resource.MONEY:
        vendValue = (v.cost ~/ 100).toDouble();
        break;
      case Resource.BEADS:
        vendValue = (v.cost ~/ 50).toDouble();
        break;
      case Resource.TRIANGLES:
        vendValue = (v.cost ~/ 200).toDouble();
        break;
      case Resource.COILS:
        vendValue = v.cost;
        break;
    }
    if (vendValue == 0) {
      vendValue = 1.0;
    }
    return vendValue; // Not sure how we got here
  }

  void setStoreCurrency(String elChecked) {
    switch (elChecked) {
      case "\$":
        storeCurrency = Resource.MONEY;
        break;
      case "B":
        storeCurrency = Resource.BEADS;
        break;
      case "C":
        storeCurrency = Resource.COILS;
        break;
      case "T":
        storeCurrency = Resource.TRIANGLES;
        break;
    }
  }

  void show() {
    showPlayerInventory();
    showPrice();
  }

  void showPlayerInventory() {
    if (lastClick != null && !storeItem) {
      lastClick = null;
    }
    List<Part> looseMachineParts = new List();
    for (PartAndLabel p in m.partAndLabelList) {
      if (p.isTangible()) {
        looseMachineParts.add(p.part);
      }
    }
    showPartList("#player_inventory", looseMachineParts);
  }

  Shop(this.p, this.m, this.v) {
    show();
    showPartList("#shop_inventory", Part.values);
    querySelector("#shop_inventory").onClick.listen(clickStoreItem);
    querySelector("#player_inventory").onClick.listen(clickPlayerItem);
    querySelector("#buy_button").onClick.listen(clickBuy);
    querySelector("#leave_shop_btn").onClick.listen(clickLeave);
    var radios = querySelectorAll("[name='store_money']");
    for (var el in radios) {
      String b = el.value;
      el.onChange.listen((e) => changeStoreMoney(b));
    }
  }

  void toggle() {
    if (visible) {
      gSetTangible(false, "quest_shop");
      gSetTangible(true, "regular_quest");
    } else {
      gSetTangible(true, "quest_shop");
      gSetTangible(false, "regular_quest");
      show();
    }
    visible = !visible;
  }

  showPartList(String s, List<Part> values) {
    String html = "";
    int i = 0;
    for (Part p in values) {
      String pname = p.name;
      String pdisplay = p.display;
      html += "<div class='unselected' id='$s$i'> $pname: $pdisplay</div>";
      i++;
    }
    var container = querySelector(s);
    container.innerHtml = html;
  }

  void clickStoreItem(MouseEvent event) {
    changeSelection(event.target, true);
  }

  void changeSelection(var target, bool arg1) {
    if (target == null) {
      return;
    }
    if (lastClick != null) {
      lastClick.classes.remove("selected");
      lastClick.classes.add("unselected");
    }
    lastClick = target;
    lastClick.classes.remove("unselected");
    lastClick.classes.add("selected");
    if (storeItem != arg1) {
      var btn = querySelector("#buy_button");
      if (arg1) {
        btn.innerHtml = "Buy";
      } else {
        btn.innerHtml = "Sell";
      }
    }
    storeItem = arg1;
    update(); // Update button enabled state
  }

  void clickPlayerItem(MouseEvent event) {
    changeSelection(event.target, false);
  }

  void clickBuy(MouseEvent event) {
    if (lastClick != null) {
      if (storeItem) {
        buyItem();
      } else {
        sellItem();
      }
    }
  }

  void sellItem() {
    int len = "#player_inventory".length;
    String val = lastClick.id;
    if (val.length > len) {
      int index = int.parse(val.substring(len));
      int curIndex = 0;
      for (PartAndLabel part in m.partAndLabelList) {
        if (part.isTangible()) {
          if (curIndex == index) {
            p.getParts().remove(part.part);
            m.initList(p.getParts());
            //p.increaseFunction(storeCurrency, getCurrentCost());
            v.decrementCost();
            show(); // Price and inventory updated
            changeSelection(querySelector("#player_inventory div"), false);
            break;
          }
          curIndex++;
        }
      }
    }
  }

  void buyItem() {
    int len = "#shop_inventory".length;
    String val = lastClick.id;
    if (val.length > len && isItemAffordable()) {
      int index = int.parse(val.substring(len));
      p.decreaseFunction(storeCurrency, getCurrentCost());
      p.addParts([Part.values[index]]);
      m.initList(p.getParts());
      v.incrementCost();
      show(); // Price and inventory updated
    }
  }

  bool isItemAffordable() {
    bool canAfford = p.resourceInt(storeCurrency) >= getCurrentCost();
    return canAfford;
  }

  void update() {
    bool enabled = !(lastClick == null || (storeItem && !isItemAffordable()));
    var b = querySelector("#buy_button");
    b.disabled = !enabled;
  }

  void changeStoreMoney(String id) {
    setStoreCurrency(id);
    showPrice();
    update();
  }

  void showPrice() {
    String printedPrice = printableResourceAmount(storeCurrency, getCurrentCost());
    querySelector("#store_cost").innerHtml = printedPrice;
  }

  void clickLeave(MouseEvent event) {
    this.toggle();
  }
  
  static String printableResourceAmount(Resource currency, double dCost) {
    bool neg = false;
    if (dCost < 0) {
      neg = true;
      dCost *= -1;
    }
    String cost = Player.comma(dCost.toDouble());
    String id = currency.abbrv;
    String printedPrice = "$cost $id";
    if (currency == Resource.MONEY) {
      if (neg) {
        printedPrice = "-\$$cost";
      } else {
        printedPrice = "\$$cost";
      }
    } else {
     if (neg) {
       printedPrice = "-" + printedPrice;
     }
    }
    return printedPrice;
  }
}

