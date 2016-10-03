part of gamesystem;

class Rule {
  static const int TYPE_RESOURCE_RATE = 1;
  static const int TYPE_RESOURCE_AMASS = 2;
  static const int ENLIGHTENMENT = 3;
  static const int EVERY_PART = 4;
  static const int CAT_CLICKS = 5;
  static const int BUILDINGS = 6;
  static const int PARTS = 7;

  final int type;
  final double data;
  final Resource r;

  const Rule(this.type, this.data, [this.r = null]);

  String toString() {
    String retVal = "";
    switch (type) {
      case TYPE_RESOURCE_RATE:
        if (data >= 0) {
          retVal = "Earn ";
        } else {
          retVal = "Lose -";
        }
        retVal += r.abbrv;
        double val = (data < 0.0) ? -data : data;
        if (val > 1000) {
          retVal += (val ~/ 1000).toString() + "K";
        } else {
          retVal += val.toInt().toString();
        }
        retVal += "/s";
        break;
      case TYPE_RESOURCE_AMASS:
        retVal = "Collect " + r.abbrv;
        if (data >= 1000000000000) {
          retVal += (data ~/ 1000000000000).toString() + "T";
        } else if (data >= 1000000000) {
          retVal += (data ~/ 1000000000).toString() + "B";
        } else if (data >= 1000000) {
          retVal += (data ~/ 1000000).toString() + "M";
        } else if (data >= 1000) {
          retVal += (data ~/ 1000).toString() + "K";
        } else {
          retVal += data.toInt().toString();
        }
        break;
      case ENLIGHTENMENT:
        retVal = data.toInt().toString() + " enlightenment";
        break;
      case EVERY_PART:
        if (data == 0) {
          retVal = "Use every slot";
        } else {
          retVal = "Every slot, nothing broken";
        }
        break;
      case CAT_CLICKS:
        retVal = "Cat Click " + data.toInt().toString() + "x";
        break;
      case BUILDINGS:
        retVal = data.toInt().toString() + " colony buildings";
        break;
      case PARTS:
        retVal = data.toInt().toString() + " machine parts";
        break;
    }
    return retVal;
  }

  bool evaluate(Player p, Village v, Machine m) {
    switch (type) {
      case TYPE_RESOURCE_RATE:
        double delta = p.resourceDelta(r);
        return (data >= 0 && delta >= data) || (data < 0 && delta <= data);
      case TYPE_RESOURCE_AMASS:
        return (p.resourceInt(r) >= data);
      case ENLIGHTENMENT:
        return v.enlightened >= data;
      case EVERY_PART:
        for (int i = 0; i < Machine.GRID_X; i++) {
          for (int j = 0; j < Machine.GRID_Y; j++) {
            if (m.getPart(i, j) == null) {
              return false;
            }
          }
        }
        if (data == 0) {
          return true;
        }
        return !m.brokenArrow;
      case CAT_CLICKS:
        return Cat.statementCount >= data;
      case BUILDINGS:
        int buildingCount = 0;
        for (Building b in Building.values) {
          if (b == Building.FIELD_01 || b == Building.FIELD_02) {
            continue;
          }
          if (b.isVisible()) {
            buildingCount++;
          }
        }
        return buildingCount >= data;
      case PARTS:
        int numParts = p.getParts().length;
        if (data == 0) {
          return numParts == data;
        }
        return numParts >= data;
    }
    return false;
  }
}

class Achievements {
  static const A01 = const Achievements(const Rule(Rule.TYPE_RESOURCE_RATE,
      -75000.0, Resource.BEADS), "Bead Ruination");
  static const A02 = const Achievements(const Rule(Rule.TYPE_RESOURCE_RATE,
      25000.0, Resource.BEADS), "Bead Manufacturer");
  static const A03 = const Achievements(const Rule(Rule.TYPE_RESOURCE_RATE,
      100000.0, Resource.MONEY), "Get Rich Quick");
  static const A04 = const Achievements(const Rule(Rule.TYPE_RESOURCE_RATE,
      -75000.0, Resource.MONEY), "Get Poor Quick");
  static const A06 = const Achievements(const Rule(Rule.TYPE_RESOURCE_RATE,
      12.0, Resource.VENDING_MACHINES), "Successful Vendor");
  static const A09 = const Achievements(const Rule(Rule.TYPE_RESOURCE_RATE,
      25000.0, Resource.TRIANGLES), "Triangle Crazy");
  static const A10 = const Achievements(const Rule(Rule.TYPE_RESOURCE_RATE,
      -250000.0, Resource.TRIANGLES), "Triangle Apocalypse");
  static const A11 = const Achievements(const Rule(Rule.TYPE_RESOURCE_RATE,
      25.0, Resource.VENDING_MACHINES), "Wildly Successful Vendor");
  static const A12 = const Achievements(const Rule(Rule.TYPE_RESOURCE_RATE,
      100.0, Resource.COILS), "Double Negator");
  static const A25 = const Achievements(const Rule(Rule.TYPE_RESOURCE_RATE, 2.0,
      Resource.FREE_LUNCHES), "Batman");
  static const A27 = const Achievements(const Rule(Rule.TYPE_RESOURCE_RATE,
      20.0, Resource.STUDENTS), "Pep Rally");
  static const A28 = const Achievements(const Rule(Rule.TYPE_RESOURCE_RATE,
      10.0, Resource.FACTORY_WORKERS), "Union Organizer");
  static const A05 = const Achievements(const Rule(Rule.TYPE_RESOURCE_AMASS,
      1000000.0, Resource.MONEY), "Millionaire");
  static const A07 = const Achievements(const Rule(Rule.TYPE_RESOURCE_AMASS,
      1000000000.0, Resource.MONEY), "Bajillionaire");
  static const A08 = const Achievements(const Rule(Rule.TYPE_RESOURCE_AMASS,
      1000000.0, Resource.BEADS), "Beadillionaire");
  static const A19 = const Achievements(const Rule(Rule.TYPE_RESOURCE_AMASS,
      50.0, Resource.STUDENTS), "Head Master");
  static const A22 = const Achievements(const Rule(Rule.TYPE_RESOURCE_AMASS,
      10.0, Resource.FREE_LUNCHES), "Lazy");
  static const A23 = const Achievements(const Rule(Rule.TYPE_RESOURCE_AMASS,
      500.0, Resource.FREE_LUNCHES), "Freeloader");
  static const Achievements A32 = const Achievements(const Rule(
      Rule.TYPE_RESOURCE_AMASS, (1.8e+23), Resource.BEADS), "You Win");
  static const A24 = const Achievements(const Rule(Rule.TYPE_RESOURCE_AMASS,
      10000.0, Resource.FREE_LUNCHES), "The Dude");
  static const A26 = const Achievements(const Rule(Rule.TYPE_RESOURCE_AMASS,
      500.0, Resource.COLONIES), "Rebuild World");
  static const A31 = const Achievements(const Rule(Rule.TYPE_RESOURCE_AMASS,
      500000000000.0, Resource.TRIANGLES), "Country Gentleman");
  static const A13 = const Achievements(const Rule(Rule.ENLIGHTENMENT, 6.0, null
      ), "Above and Beyond");
  static const A14 = const Achievements(const Rule(Rule.ENLIGHTENMENT, 10.0,
      null), "Lighter than Helium");
  static const A15 = const Achievements(const Rule(Rule.EVERY_PART, 0.0, null),
      "Mad Tinkerer");
  static const A16 = const Achievements(const Rule(Rule.EVERY_PART, 1.0, null),
      "Mad Genuis");
  static const A17 = const Achievements(const Rule(Rule.CAT_CLICKS, 10.0, null),
      "Pet the Cat");
  static const A18 = const Achievements(const Rule(Rule.CAT_CLICKS, 50.0, null),
      "Merciless Poking");
  static const A20 = const Achievements(const Rule(Rule.BUILDINGS, 6.0, null),
      "Growing Town");
  static const A21 = const Achievements(const Rule(Rule.BUILDINGS, 8.0, null),
      "Mayor");
  static const A29 = const Achievements(const Rule(Rule.PARTS, 0.0, null),
      "Starting Over");
  static const A30 = const Achievements(const Rule(Rule.PARTS, 100.0, null),
      "Hard To Buy Presents For");

  final Rule rule;
  final String name;

  static get values => [A01, A02, A03, A04, A05, A06, A07, A08, A09, A10, A11,
      A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22, A23, A24, A25, A26, A27,
      A28, A29, A30, A31, A32];
  const Achievements(this.rule, this.name);

  static Map toJson() {
    List list = new List();
    for (Achievements a in unlocked) {
      list.add(values.indexOf(a));
    }
    Map map = new Map();
    map["unlocked"] = list;
    return map;
  }

  static void load(Map map) {
    unlocked.clear();
    if (map == null) {
      return;
    }
    List list = map["unlocked"];
    if (list == null) {
      return;
    }
    for (int i in list) {
      unlocked.add(values[i]);
    }
  }

  static List<Achievements> unlocked = new List();

  bool check(Player p, Village v, Machine m) {
    if (unlocked.contains(this) || rule == null) {
      return false;
    }
    return rule.evaluate(p, v, m);
  }

  show(var pop, bool append, [bool bold = null]) {
    String title = "Badge: " + this.name;
    String desc = rule.toString();
    int count = 0;
    while (title.length > desc.length) {
      desc += " ";
    }
    while (title.length < desc.length) {
      title += " ";
    }
    String spaces = "    ";
    title = "|" + spaces + title + spaces + "|";
    desc = "|" + spaces + desc + spaces + "|";
    String margin = "";
    for (int i = 0; i < desc.length - 2; i++) {
      margin += "-";
    }
    margin = "+" + margin + "+\n";
    String bolden = bold == true ? "<b>" : "<font color='gray'>";
    String unbolden = bold == true ? "</b>" : "</font>";
    if (bold == null) {
      bolden = "";
      unbolden = "";
    }
    if (append) {
      pop.innerHtml += bolden + margin + title + "\n" + desc + "\n" + margin +
          unbolden;
    } else {
      pop.innerHtml = bolden + margin + title + "\n" + desc + "\n" + margin +
          unbolden;
    }
  }

  static const int COUNTDOWN_LENGTH = 3;
  static int countdown = 0;

  static void doChecks(Player p, Village v, Machine m) {
    if (countdown > 0) {
      countdown--;
      if (countdown == 0) {
        gSetTangible(false, "popup");
      }
    }
    var pop = querySelector("#popup_contents");
    for (Achievements a in values) {
      if (a.check(p, v, m)) {
        bool append = countdown > 0;
        unlocked.add(a);
        a.show(pop, append);
        countdown += COUNTDOWN_LENGTH;
      }
    }
    if (countdown > 0) {
      gSetTangible(true, "popup");
      Achievements.render();
    }
  }

  static void render() {
    var pop = querySelector("#achievements");
    pop.innerHtml =
        "<table><tr><td valign=top id='atr1'></td><td valign=top id='atr2'></td><td valign=top id='atr3'></td></tr></table>";
    List trList = new List();
    trList.add(querySelector("#atr1"));
    trList.add(querySelector("#atr2"));
    trList.add(querySelector("#atr3"));
    int i = 0;
    for (Achievements a in values) {
      a.show(trList[i++ % 3], true, unlocked.contains(a));
    }
  }
}
