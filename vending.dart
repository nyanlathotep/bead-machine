part of gamesystem;

class VendingMachine {

  double cost = 50.0;
  bool visible = false;
  int vendCount = 0;
  double increment = 1.5;
  Resource currency = Resource.MONEY;
  bool colorCycle = false;
  
  String get showCost => currency.abbrv + cost.toInt().toString();

  Map toJson() {
    Map map = new Map();
    map["cost"] = cost;
    map["visible"] = visible;
    map["vendCount"] = vendCount;
    map["increment"] = increment;
    map["colorCycle"] = colorCycle;
    map["currency"] = currency.value;
    return map;
  }
  
  void load(Map map) {
    cost = map["cost"].toDouble();
    visible = map["visible"];
    vendCount = map["vendCount"];
    increment = map["increment"];
    colorCycle = map["colorCycle"] == true;
    int c = map["currency"];
    currency = Resource.values[c == null ? 0 : c];
    updateVendCost();
  }
  
  final String ART =
  "Vending Machine\n" +
  " ┌───────────┐\n" +
  " │ O   O   O │\n" +
  " │ O   O   O │\n" +
  " │ O   O   O │\n" +
  " │ O   O   O │\n" +
  " │ O   O   O │\n" +
  " ├───────────┤\n" +
  " │╔═════════╗│\n" +
  " │╚═════════╝│\n" +
  " └───────────┘\n";

  List get progression => colorCycle ? progressionB : progressionA;
  
  static const List progressionA = const [
      const [Part.HOPPER_A, Part.CONVERTER_A],
      const [Part.DOUBLER_A, Part.DOUBLER_A],
      const [Part.CORNER_A, Part.CONVERTER_A],
      const [Part.DOUBLER_B, Part.DOUBLER_B],
      const [Part.HOPPER_C, Part.UNLUNCHER],
      const [Part.SPLITTER_A, Part.CONDUIT_B, Part.CONDUIT_A, Part.CORNER_B],
      const [Part.CONVERTER_B, Part.CONVERTER_C],
      const [Part.HOPPER_B, Part.DOUBLER_B],
      const [Part.HOPPER_D, Part.TRANSMUTER_A],
      const [Part.HOPPER_E, Part.HOPPER_F, Part.SINK_A],
      const [Part.SHUFFLER]
    ];

  static const List progressionB = const [
      const [Part.COILER],
      const [Part.CORNER_C],
      const [Part.UNCOILER],
      const [Part.REVERSE_CORNER, Part.CONVERTER_D],
      const [Part.PUZZLER, Part.CORNER_B],
      const [Part.COILER],
      const [Part.UNCOILER],
      const [Part.COILER],
      const [Part.CORNER_C],
      const [Part.UNCOILER],
      const [Part.PUZZLER, Part.CORNER_B],
      const [Part.CONDUIT_C],
      const [Part.COILER],
      const [Part.UNCOILER],
      const [Part.COILER],
      const [Part.UNCOILER],
      const [Part.REVERSE_CORNER, Part.CONVERTER_D],
      const [Part.PUZZLER, Part.CORNER_B],
      const [Part.COILER],
      const [Part.UNCOILER],
      const [Part.PUZZLER, Part.CORNER_B],
      const [Part.HOPPER_A, Part.CONVERTER_A],
      const [Part.DOUBLER_A, Part.DOUBLER_A],
      const [Part.CORNER_A, Part.CONVERTER_A],
      const [Part.DOUBLER_B, Part.DOUBLER_B],
      const [Part.HOPPER_C, Part.UNLUNCHER],
      const [Part.HOPPER_G],
      const [Part.SPLITTER_A, Part.CONDUIT_B, Part.CONDUIT_A, Part.CONDUIT_C],
      const [Part.CONVERTER_B, Part.CONVERTER_C],
      const [Part.HOPPER_B, Part.DOUBLER_B],
      const [Part.HOPPER_D, Part.TRANSMUTER_A],
      const [Part.HOPPER_E, Part.HOPPER_F, Part.SINK_A],
      const [Part.SHUFFLER]
    ];
  
  List<Part> vend() {
    if (cost == 0) {
      cost = 5.0;
    }
    incrementCost();
    bool wrapped = false;
    if (vendCount == progression.length) {
      vendCount = 0;
      wrapped = true;
    }
    var ret = progression[vendCount];
    StringBuffer buffer = new StringBuffer("CA-CHUNK! The vending machine spits out " +
        ret.length.toString() + " item" + (ret.length>1?"s":"") + ".<br>");
    buffer.write("<ul>");
    for (Part p in ret) {
      buffer.write("<li>" + p.name + ": " + p.display + "</li>");
    }
    buffer.write("</ul>");
    if (wrapped) {
      buffer.write("(wrapped)");
    }
    showStatus(buffer.toString());
    vendCount++;
    return ret;
  }

  void decrementCost() {
    // Inherently, it goes down slower.
    cost = (cost.toInt() ~/ (increment - 0.25)).toDouble();
    if (cost < 10000) {
      increment = 1.5;
    }
    if (cost < 5) {
      cost = 5.0;
    }
    updateVendCost();
  }
  
  void incrementCost() {
    cost = (cost * increment).toInt().toDouble();
    if (cost > 10000) {
      // Once you have this many parts, it's much harder to get more.
      increment = 2.5;
    }
    updateVendCost();
  }

  void updateVendCost() {
    querySelector("#vend_btn").text = "Vend ($showCost)";
  }

  void failToVend() {
    var cCost = currency.abbrv + Player.comma(cost);
    showStatus("You need at least $cCost to get something from the vending machine.");
  }
  
  void showStatus(String status) {
    querySelector("#vend_msg").innerHtml = status;
  }
  
  void setVisible(bool v) {
    visible = v;
    gSetVisible(v, "vend_container");
  }
  
  int tick = 0;

  void show() {
    String art;
    if (colorCycle) {
      List<String> foo = ART.split("\n");
      List<String> bar = new List<String>();
      int range = 255;
      tick++;
      var t = tick;
      var frequency = 0.5;
      for (String s in foo) {
        int r = (sin(frequency*t + 0) * 127 + 128).toInt();
        int g = (sin(frequency*t + 2) * 127 + 128).toInt();
        int b = (sin(frequency*t + 4) * 127 + 128).toInt();
        t++;
        bar.add("<font color='#"
            + pad(r.toRadixString(16))
            + pad(g.toRadixString(16))
            + pad(b.toRadixString(16))
            + "'>" + gAsciiArt(s) + "</font>");
      }
      art = bar.join("<br>");
    } else {
      art = gAsciiArt(ART);
    }
    querySelector("#vending_machine")
      ..innerHtml = art;
  }

  String pad(String inString) {
    if (inString.length < 2) {
      return "0" + inString;
    }
    return inString;
  }

  void upgrade() {
    cost = 0.0;
    colorCycle = true;
    currency = Resource.COILS;
    vendCount = 0;
    increment = 1.5;
    updateVendCost();
  }
}
