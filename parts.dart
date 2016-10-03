part of gamesystem;

class Dir {
  static const UP = const Dir(0, "UP");
  static const DN = const Dir(1, "DN");
  static const RT = const Dir(2, "RT");
  static const LT = const Dir(3, "LT");

  static get values => [UP, DN, LT, RT];

  final int value;
  final String name;

  Dir opposite() {
    switch (value) {
      case 0:
        return DN;
      case 1:
        return UP;
      case 2:
        return LT;
      case 3:
        return RT;
    }
    return null;
  }

  const Dir(this.value, this.name);
}

class PartResults {
  Dir direction;
  Resource resource;
  double amount;
}

class Part {

  int compareTo(Part p) {
    return (name + display).compareTo(p.name + p.display);
  }

  Map toJson() {
    Map map = new Map();
    map["index"] = values.indexOf(this);
    return map;
  }

  static Part load(Map map) {
    if (map == null) {
      return null;
    }
    return Part.values[map["index"]];
  }

  final String name;
  final String display;
  final List<Dir> inConnections;
  final List<Dir> outConnections;
  final Function process;
  // Process function returns a list of results (direction, resource, amount)
  final List<Resource> accept;
  final double requires;

  const
      Part(this.name, this.display, this.inConnections, this.outConnections, this.process, this.accept, [this.requires
      = 1.0]);

  // Crossed conduits, in V -> out V / in H -> out H
  // FL -> Student (add Cloner achievement)
  // 1000C -> V
  // V -> 1000C

  static get values => [HOPPER_A, HOPPER_B, HOPPER_C, HOPPER_D, HOPPER_E,
      HOPPER_F, CONVERTER_A, CONVERTER_B, CONVERTER_C, DOUBLER_A, DOUBLER_B,
      CONDUIT_A, CONDUIT_B, UNLUNCHER, CORNER_A, CORNER_B, SPLITTER_A, TRANSMUTER_A,
      SINK_A, SHUFFLER, COILER, CORNER_C, UNCOILER, REVERSE_CORNER, PUZZLER,
      CONVERTER_D, RECRUITER, CONDUIT_C, HOPPER_G, CONVERTER_E, CONVERTER_F,
      CONVERTER_G, CONDUIT_D, HOPPER_H, SINK_B];

  static const RECRUITER = const Part("Recruiter", "[S->W]", const [Dir.UP],
      const [Dir.DN], processRecruiter, const [Resource.STUDENTS]);

  static const CONVERTER_E = const Part("Converter", "[FL->S]", const [Dir.LT],
      const [Dir.RT], processConverterE, const [Resource.FREE_LUNCHES]);

  static const CONVERTER_F = const Part("Converter", "[V->1kxC]", const
      [Dir.LT], const [Dir.RT], processConverterF, const [Resource.VENDING_MACHINES]);

  static const CONVERTER_G = const Part("Converter", "[1kxC->V]", const
      [Dir.LT], const [Dir.RT], processConverterG, const [Resource.COILS]);

  static const HOPPER_G = const Part("Hopper", "[+50V->]", const [], const
      [Dir.RT], processHopperG, const [Resource.VENDING_MACHINES], 50.0);

  static const HOPPER_H = const Part("Hopper", "[+S->]", const [], const
      [Dir.DN], processHopperH, const [Resource.STUDENTS], 1.0);

  static const CONVERTER_D = const Part("Converter", "[FL->C]", const [Dir.LT],
      const [Dir.RT], processConverterD, const [Resource.FREE_LUNCHES]);

  static const REVERSE_CORNER = const Part("Corner (B)", "[C<-C]", const
      [Dir.UP], const [Dir.LT], processReverseCorner, const [Resource.COILS]);

  static const PUZZLER = const Part("Puzzler", "[*->**/-*]", const [Dir.LT],
      const [Dir.RT, Dir.DN], processPuzzler, Resource.values);

  static const UNCOILER = const Part("Uncoiler", "[-10xC<-C]", const [Dir.RT],
      const [Dir.LT], processUncoiler, const [Resource.COILS]);

  static const CORNER_C = const Part("Corner (A)", "[C<-C]", const [Dir.RT],
      const [Dir.DN], processCornerC, const [Resource.COILS]);

  static const COILER = const Part("Coiler", "[C<-\$+]", const [], const
      [Dir.LT], processCoiler, const [Resource.MONEY]);

  static const SINK_A = const Part("Sink", "[*->]", const [Dir.LT], const [],
      processSinkA, Resource.values);

  static const SINK_B = const Part("Sink (V)", "[*->]", const [Dir.UP], const [],
      processSinkB, Resource.values);

  static const TRANSMUTER_A = const Part("Transmuter", "[*->\$]", const
      [Dir.LT], const [Dir.RT], processTransmuterA, Resource.values);

  static const HOPPER_A = const Part("Hopper", "[+\$->]", const [], const
      [Dir.RT], processHopperA, const [Resource.MONEY]);

  static const HOPPER_B = const Part("Hopper", "[+T->]", const [], const
      [Dir.RT], processHopperB, const [Resource.TRIANGLES]);

  static const HOPPER_C = const Part("Hopper", "[+FL->]", const [], const
      [Dir.RT], processHopperC, const [Resource.FREE_LUNCHES]);

  static const HOPPER_D = const Part("Hopper", "[+100B->]", const [], const
      [Dir.RT], processHopperD, const [Resource.BEADS], 100.0);

  static const HOPPER_E = const Part("Hopper", "[+25T->]", const [], const
      [Dir.RT], processHopperE, const [Resource.TRIANGLES], 25.0);

  static const HOPPER_F = const Part("Hopper", "[+\$1000->]", const [], const
      [Dir.RT], processHopperF, const [Resource.MONEY], 1000.0);

  static const CONVERTER_A = const Part("Converter", "[\$->B]", const [Dir.LT],
      const [Dir.RT], processConverterA, const [Resource.MONEY]);

  static const CONVERTER_B = const Part("Converter", "[4xB->T]", const [Dir.LT],
      const [Dir.RT], processConverterB, const [Resource.BEADS]);

  static const CONVERTER_C = const Part("Converter", "[T->\$100]", const
      [Dir.LT], const [Dir.RT], processConverterC, const [Resource.TRIANGLES]);

  static const DOUBLER_A = const Part("Doubler", "[\$->\$\$]", const [Dir.LT],
      const [Dir.RT, Dir.DN], processDoublerA, const [Resource.MONEY]);

  static const DOUBLER_B = const Part("Doubler", "[B->BB]", const [Dir.LT],
      const [Dir.RT], processDoublerB, const [Resource.BEADS]);

  static const UNLUNCHER = const Part("Unluncher", "[FL->\$1k]", const [Dir.LT],
      const [Dir.RT], processUnluncher, const [Resource.FREE_LUNCHES]);

  static const CORNER_A = const Part("Corner", "[\$->\$]", const [Dir.UP], const
      [Dir.RT], processCornerA, const [Resource.MONEY]);

  static const CORNER_B = const Part("Corner", "[*->*]", const [Dir.UP], const
      [Dir.RT], processCornerB, Resource.values);

  static const SPLITTER_A = const Part("Splitter", "[\$->B+\$]", const [Dir.LT],
      const [Dir.RT, Dir.DN], processSplitterA, const [Resource.MONEY]);

  static const CONDUIT_A = const Part("Conduit(H)", "[*->*]", const [Dir.LT],
      const [Dir.RT], processConduitA, Resource.values);

  static const CONDUIT_B = const Part("Conduit(V)", "[*->*]", const [Dir.UP],
      const [Dir.DN], processConduitB, Resource.values);

  static const CONDUIT_C = const Part("Conduit(B)", "[*<-*]", const [Dir.RT],
      const [Dir.LT], processConduitC, Resource.values);

  static const CONDUIT_D = const Part("Conduit(H/V)", "[*->*]", const [Dir.LT,
      Dir.UP], const [Dir.RT, Dir.DN], processConduitD, Resource.values);

  static const SHUFFLER = const Part("Shuffler", "[*->?]", const [Dir.LT], const
      [Dir.RT], processShuffler, Resource.values);

  static Part findPart(String name) {
    for (Part p in values) {
      if (p.name == name) {
        return p;
      }
    }
    return null;
  }

  String upIcon() {
    if (inConnections.contains(Dir.UP)) {
      return "v";
    }
    if (outConnections.contains(Dir.UP)) {
      return "^";
    }
    return "&nbsp;";
  }

  String downIcon() {
    if (inConnections.contains(Dir.DN)) {
      return "^";
    }
    if (outConnections.contains(Dir.DN)) {
      return "v";
    }
    return "&nbsp;";
  }

  String leftIcon() {
    if (inConnections.contains(Dir.LT)) {
      return "&gt;";
    }
    if (outConnections.contains(Dir.LT)) {
      return "&lt;";
    }
    return "&nbsp;";
  }

  String rightIcon() {
    if (inConnections.contains(Dir.RT)) {
      return "&lt;";
    }
    if (outConnections.contains(Dir.RT)) {
      return "&gt;";
    }
    return "&nbsp;";
  }

  String toHtml() {
    String buffer = "<table border=0 width=100%>";
    // FIRST ROW
    buffer += "<tr><td></td><td><center id='UP_arrow'>" + upIcon() +
        "</center></td><td></td></tr>";
    // SECOND ROW
    buffer += "<tr><td id='LT_arrow'>" + leftIcon() + "</td><td>";
    buffer += "------<br>" + display + "<br>------<br><center>" + name +
        "</center>";
    buffer += "</td><td id='RT_arrow'>" + rightIcon() + "</td></tr>";
    // THIRD ROW
    buffer += "<tr><td></td><td><center id='DN_arrow'>" + downIcon() +
        "</center></td><td></td></tr>";
    buffer += "</table>";

    return buffer;
  }

  String getIconForDirection(Dir direction) {
    switch (direction) {
      case Dir.RT:
        return this.rightIcon();
      case Dir.LT:
        return this.leftIcon();
      case Dir.UP:
        return this.upIcon();
      case Dir.DN:
        return this.downIcon();
    }
    return null;
  }
}

List<PartResults> processCoiler(Resource r, double amount, Dir from) {
  if (from == null && r == Resource.MONEY) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = Resource.COILS;
    result.direction = Dir.LT;
    return [result];
  }
  return [];
}

List<PartResults> processHopperA(Resource r, double amount, Dir from) {
  return processRegularHopper(from, r, Resource.MONEY, amount);
}

List processRegularHopper(Dir from, Resource r, Resource requires, double
    amount, [Dir out = Dir.RT]) {
  if (from == null && r == requires) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = r;
    result.direction = out;
    return [result];
  }
  return [];
}

List<PartResults> processHopperB(Resource r, double amount, Dir from) {
  return processRegularHopper(from, r, Resource.TRIANGLES, amount);
}

List<PartResults> processHopperG(Resource r, double amount, Dir from) {
  return processRegularHopper(from, r, Resource.VENDING_MACHINES, amount);
}

List<PartResults> processHopperH(Resource r, double amount, Dir from) {
  return processRegularHopper(from, r, Resource.STUDENTS, amount, Dir.DN);
}

List<PartResults> processHopperC(Resource r, double amount, Dir from) {
  if (from == null && r == Resource.FREE_LUNCHES) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = r;
    result.direction = Dir.RT;
    return [result];
  }
  return [];
}

List<PartResults> processHopperD(Resource r, double amount, Dir from) {
  if (from == null && r == Resource.BEADS) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = r;
    result.direction = Dir.RT;
    return [result];
  }
  return [];
}

List<PartResults> processHopperE(Resource r, double amount, Dir from) {
  if (from == null && r == Resource.TRIANGLES) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = r;
    result.direction = Dir.RT;
    return [result];
  }
  return [];
}

List<PartResults> processHopperF(Resource r, double amount, Dir from) {
  if (from == null && r == Resource.MONEY) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = r;
    result.direction = Dir.RT;
    return [result];
  }
  return [];
}

List<PartResults> processConduitA(Resource r, double amount, Dir from) {
  if (from == Dir.LT) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = r;
    result.direction = Dir.RT;
    return [result];
  }
  return [];
}

List<PartResults> processSinkA(Resource r, double amount, Dir from) {
  if (from == Dir.LT) {
    PartResults result = new PartResults();
    result.amount = 0.0;
    result.resource = r;
    result.direction = Dir.RT;
    return [result];
  }
  return [];
}

List<PartResults> processSinkB(Resource r, double amount, Dir from) {
  if (from == Dir.UP) {
    PartResults result = new PartResults();
    result.amount = 0.0;
    result.resource = r;
    result.direction = Dir.DN;
    return [result];
  }
  return [];
}

List<PartResults> processShuffler(Resource r, double amount, Dir from) {
  if (from == Dir.LT) {
    PartResults result = new PartResults();
    result.amount = amount;
    var rng = new Random();
    int rnd = rng.nextInt(3);
    var valid = [Resource.BEADS, Resource.MONEY, Resource.TRIANGLES];
    result.resource = valid[rnd];
    result.direction = Dir.RT;
    return [result];
  }
  return [];
}

List<PartResults> processConduitB(Resource r, double amount, Dir from) {
  if (from == Dir.UP) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = r;
    result.direction = Dir.DN;
    return [result];
  }
  return [];
}

List<PartResults> processConduitD(Resource r, double amount, Dir from) {
  if (from == Dir.LT) {
    return passTo(r, amount, Dir.RT);
  } else if (from == Dir.UP) {
    return passTo(r, amount, Dir.DN);
  }
  return [];
}

passTo(Resource r, double amount, Dir d) {
  PartResults result = new PartResults();
  result.amount = amount;
  result.resource = r;
  result.direction = d;
  return [result];
}

List<PartResults> processConduitC(Resource r, double amount, Dir from) {
  if (from == Dir.RT) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = r;
    result.direction = Dir.LT;
    return [result];
  }
  return [];
}

List<PartResults> processConverterA(Resource r, double amount, Dir from) {
  if (Part.CONVERTER_A.accept.contains(r) && from == Dir.LT) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = Resource.BEADS;
    result.direction = Dir.RT;
    return [result];
  }
  return [];
}

List<PartResults> processConverterB(Resource r, double amount, Dir from) {
  if (Part.CONVERTER_B.accept.contains(r) && from == Dir.LT && (amount >= 4 ||
      amount <= -4)) {
    PartResults result = new PartResults();
    result.amount = (amount ~/ 4).toDouble();
    result.resource = Resource.TRIANGLES;
    result.direction = Dir.RT;
    return [result];
  }
  return [];
}


List<PartResults> processRecruiter(Resource r, double amount, Dir from) {
  return processConverter(Part.RECRUITER, r, amount, from,
      Resource.FACTORY_WORKERS, 1, 1);
}


List<PartResults> processConverterE(Resource r, double amount, Dir from) {
  return processConverter(Part.CONVERTER_E, r, amount, from, Resource.STUDENTS,
      1, 1);
}

List<PartResults> processConverterF(Resource r, double amount, Dir from) {
  return processConverter(Part.CONVERTER_F, r, amount, from, Resource.COILS, 1,
      1000);
}

List<PartResults> processConverterG(Resource r, double amount, Dir from) {
  return processConverter(Part.CONVERTER_G, r, amount, from,
      Resource.VENDING_MACHINES, 1000, 1 / 1000);
}

List<PartResults> processConverterD(Resource r, double amount, Dir from) {
  return processConverter(Part.CONVERTER_D, r, amount, from, Resource.COILS, 1,
      1);
}

processConverter(Part p, Resource inResource, double amount, Dir from, Resource
    outResource, requiredAmount, multiplier) {
  if (p.accept.contains(inResource) && p.inConnections.contains(from) && (amount
      >= requiredAmount || amount <= -requiredAmount)) {
    PartResults result = new PartResults();
    result.amount = (amount * multiplier).round().toDouble();
    result.resource = outResource;
    result.direction = p.outConnections[0];
    return [result];
  }
  return [];
}

List<PartResults> processConverterC(Resource r, double amount, Dir from) {
  if (Part.CONVERTER_C.accept.contains(r) && from == Dir.LT) {
    PartResults result = new PartResults();
    result.amount = amount * 100.0;
    result.resource = Resource.MONEY;
    result.direction = Dir.RT;
    return [result];
  }
  return [];
}


List<PartResults> processTransmuterA(Resource r, double amount, Dir from) {
  if (from == Dir.LT) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = Resource.MONEY;
    result.direction = Dir.RT;
    return [result];
  }
  return [];
}

List<PartResults> processCornerA(Resource r, double amount, Dir from) {
  if (r == Resource.MONEY && from == Dir.UP) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = r;
    result.direction = Dir.RT;
    return [result];
  }
  return [];
}

List<PartResults> processCornerB(Resource r, double amount, Dir from) {
  if (from == Dir.UP) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = r;
    result.direction = Dir.RT;
    return [result];
  }
  return [];
}


List<PartResults> processReverseCorner(Resource r, double amount, Dir from) {
  if (from == Dir.UP && r == Resource.COILS) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = r;
    result.direction = Dir.LT;
    return [result];
  }
  return [];
}

List<PartResults> processCornerC(Resource r, double amount, Dir from) {
  if (from == Dir.RT && r == Resource.COILS) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = r;
    result.direction = Dir.DN;
    return [result];
  }
  return [];
}

List<PartResults> processSplitterA(Resource r, double amount, Dir from) {
  if (r == Resource.MONEY && from == Dir.LT) {
    PartResults result = new PartResults();
    result.amount = amount;
    result.resource = r;
    result.direction = Dir.RT;
    PartResults result2 = new PartResults();
    result2.amount = amount;
    result2.resource = Resource.BEADS;
    result2.direction = Dir.DN;
    return [result, result2];
  }
  return [];
}

List<PartResults> processUncoiler(Resource r, double amount, Dir from) {
  if (r == Resource.COILS && from == Dir.RT) {
    PartResults r = new PartResults();
    r.amount = -10 * amount;
    r.resource = Resource.COILS;
    r.direction = Dir.LT;
    return [r];
  }
  return [];
}

List<PartResults> processUnluncher(Resource r, double amount, Dir from) {
  if (Part.UNLUNCHER.accept.contains(r) &&
      Part.UNLUNCHER.inConnections.contains(from) && from == Dir.LT) {
    PartResults r = new PartResults();
    r.amount = amount * 1000;
    r.resource = Resource.MONEY;
    r.direction = Dir.RT;
    return [r];
  }
  return [];
}

List<PartResults> processDoublerA(Resource r, double amount, Dir from) {
  if (r == Resource.MONEY && from == Dir.LT) {
    PartResults result1 = new PartResults();
    result1.amount = amount;
    result1.resource = r;
    result1.direction = Dir.RT;
    PartResults result2 = new PartResults();
    result2.amount = amount;
    result2.resource = r;
    result2.direction = Dir.DN;
    return [result1, result2];
  }
  return [];
}

List<PartResults> processPuzzler(Resource r, double amount, Dir from) {
  if (from == Dir.LT) {
    PartResults result1 = new PartResults();
    result1.amount = 2 * amount;
    result1.resource = r;
    result1.direction = Dir.RT;
    PartResults result2 = new PartResults();
    result2.amount = -amount;
    result2.resource = r;
    result2.direction = Dir.DN;
    return [result1, result2];
  }
  return [];
}

List<PartResults> processDoublerB(Resource r, double amount, Dir from) {
  if (r == Resource.BEADS && from == Dir.LT) {
    PartResults result = new PartResults();
    result.amount = amount * 2;
    result.resource = r;
    result.direction = Dir.RT;
    return [result];
  }
  return [];
}
