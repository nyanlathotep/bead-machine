part of gamesystem;

class Player {

  // **** MEMBERS ****
  List<double> resources = new List(Resource.values.length);
  double increaseAmount = 1.0;
  List<Part> parts = new List();

  // **** CONSTRUCTOR ****
  Player() {
    for (int i = 0; i < Resource.values.length; i++) {
      resources[i] = 0.0;
    }
  }

  // **** STATE MANAGEMENT ***
  Map toJson() {
    Map map = new Map();
    map["resources"] = resources;
    map["parts"] = parts;
    return map;
  }

  void load(Map map) {
    List loadedResources = map["resources"];
    int i = 0;
    for (var amt in loadedResources) {
      resources[i++] = amt.toDouble();
    }
    for (Resource r in Resource.values) {
      lastResourceCount[r] = resources[r.value];
    }
    parts.clear();
    for (Map m in map["parts"]) {
      parts.add(Part.load(m));
    }
  }

  // **** INVENTORY MANAGEMENT ****
  void addParts(List<Part> p) {
    parts.addAll(p);
  }

  List<Part> getParts() {
    return parts;
  }

  // **** RESOURCE MANAGEMENT ****
  String resourceString(Resource r) {
    String retVal = comma(resourceInt(r));
    if (r.max != -1) {
      retVal += "/" + comma(r.max);
    }
    return retVal;
  }

  double resourceDelta(Resource r) {
    return lastResourceDelta[r];
  }

  double resourceInt(Resource r) {
    return resources[r.value];
  }

  static bool clampedStudents = false;

  void increaseFunction(Resource r, double amount) {
    //if (amount != 0 && resources[r.value] + amount == resources[r.value]) {
    //  print("Cannot add increase " + r.toString() + " by $amount");
    //}
    resources[r.value] += amount;
    //print("Increase " + r.toString() + " by " + amount.toString() + " to "
    //    + resources[r.value].toInt().toString());
    if (r == Resource.STUDENTS) {
      clampedStudents = false;
      if (resources[r.value] > Resource.STUDENTS.max) {
        resources[r.value] = Resource.STUDENTS.max;
        clampedStudents = true;
        // print("** Reduced to " + resources[r.value].toString());
      }
    } else if (r == Resource.FACTORY_WORKERS) {
      if (resources[r.value] > Resource.FACTORY_WORKERS.max) {
        resources[r.value] = Resource.FACTORY_WORKERS.max;
      }
    }
    if (resources[r.value] < 0) {
      resources[r.value] = 0.0;
    }
  }

  void decreaseFunction(Resource r, double amount) {
    resources[r.value] -= amount;
  }

  // **** DISPLAY FUNCTIONS *****
  void showResources(Village v) {
    showMoney();
    showLunches();
    showBeads();
    showTriangles();
    showStudents();
    showVending();
    showWorkers();
    showCoils();
    showEnlightenment(v);
  }

  var lastEnlightened = 0;

  void showEnlightenment(Village v) {
    String element = "enlightenment";
    querySelector("#$element").text = v.enlightened.toString();
    int newValue = v.enlightened;
    int oldValue = lastEnlightened;
    Element delta = querySelector("#" + element + "_delta");
    if (newValue < oldValue) {
      delta.innerHtml = ("<font color=red>(-" + (oldValue - newValue).toString()
          + ")</font>");
    } else if (newValue > oldValue) {
      delta.innerHtml = ("<font color=green> (+" + (newValue -
          oldValue).toString() + ")</font>");
    } else {
      delta.innerHtml = "";
    }
    lastEnlightened = newValue;
    if (newValue > 0) {
      querySelector("#" + element + "_container").classes.remove("invisible");
    }
  }

  void showCoils() {
    showLabel("coil", Resource.COILS);
  }

  void showBeads() {
    showLabel("player_beads", Resource.BEADS);
  }

  void showTriangles() {
    showLabel("player_triangles", Resource.TRIANGLES);
  }

  void showMoney() {
    showLabel("player_money", Resource.MONEY);
  }

  void showLunches() {
    showLabel("free_lunches", Resource.FREE_LUNCHES);
  }

  void showStudents() {
    showLabel("student", Resource.STUDENTS);
  }

  void showVending() {
    showLabel("vending_machines", Resource.VENDING_MACHINES);
  }

  void showWorkers() {
    showLabel("worker", Resource.FACTORY_WORKERS);
  }

  HashMap<Resource, double> lastResourceCount = new HashMap();
  HashMap<Resource, double> lastResourceDelta = new HashMap();

  void showLabel(String element, Resource r) {
    querySelector("#$element").text = resourceString(r);
    double newValue = resourceInt(r);
    double oldValue = lastResourceCount[r];
    if (oldValue == null) {
      oldValue = 0.0;
    }
    Element delta = querySelector("#" + element + "_delta");
    if (newValue < oldValue) {
      delta.innerHtml = ("<font color=red>(-" + comma(oldValue - newValue) +
          ")</font>");
    } else if (newValue > oldValue) {
      delta.innerHtml = ("<font color=green> (+" + comma(newValue - oldValue) +
          ")</font>");
    } else {
      delta.innerHtml = "";
    }
    lastResourceDelta[r] = newValue - oldValue;
    lastResourceCount[r] = newValue;
    if (newValue > 0) {
      querySelector("#" + element + "_container").classes.remove("invisible");
    }
  }

  static String pad3(double i) {
    String retVal = i.toInt().toString();
    while (retVal.length < 3) {
      retVal = "0" + retVal;
    }
    return retVal;
  }

  static String comma(double i) {
    if (i.toString().contains("e+")) {
      return i.toString();
    }
    double iBack = i;
    String retVal = (i >= 1000 ? pad3(i % 1000) : i.toInt().toString());
    i = (i ~/ 1000).toDouble();
    while (i > 0) {
      retVal = (i >= 1000 ? pad3(i % 1000) : i.toInt().toString()) + "," +
          retVal;
      i = (i ~/ 1000).toDouble();
    }
    return retVal;
  }
}
