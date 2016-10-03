part of gamesystem;

class Building {

  final String name;
  final List<double> cost;
  final List<Resource> costType;
  final Resource outputType;
  final double outputAmount;
  final String htmlStruct;
  final String htmlLabel;
  final int rows;
  final Function processInternal;

  const Building(this.name, this.cost, this.costType, this.htmlStruct, this.htmlLabel,
      this.rows, this.outputType, this.outputAmount, this.processInternal);

  static List<Building> get values => [SCHOOL,
                        FACTORY,
                        BLDG_02,
                        BLDG_03,
                        DEPOT,
                        HOVEL,
                        FARM,
                        STORE,
                        DORM,
                        TOOL_FACTORY,
                        FIELD_01,
                        FIELD_02
                        ];

  static const SCHOOL = const Building("SCHOOL", const [30000.0], const [Resource.MONEY], "school",
      "schoolLabel", 1, Resource.STUDENTS, 1.0, schoolProcess);

  static const FACTORY = const Building("FACTORY", const [7000.0], const [Resource.BEADS], "bld_01",
      "factoryLabel", 3, Resource.VENDING_MACHINES, 1.0, factoryProcess);

  static const BLDG_02 = const Building("--", const [50.0], const [Resource.VENDING_MACHINES], "bld_02",
      "", 5, null, 0.0, genericProcess);

  static const BLDG_03 = const Building("--", const [70.0], const [Resource.MONEY], "bld_03",
      "", 2, null, 0.0, genericProcess);

  static const DEPOT = const Building("DEPOT", 
      const [10.0, 100.0, 1000.0, 10.0],
      const [Resource.STUDENTS, Resource.VENDING_MACHINES, Resource.COILS, Resource.FACTORY_WORKERS], 
      "bld_04", "", 5, null, 0.0, depotProcess);

  static const HOVEL = const Building("--", const [70.0], const [Resource.MONEY], "bld_05",
      "", 4, null, 0.0, genericProcess);

  static const FARM = const Building("--", const [70.0], const [Resource.MONEY], "bld_06",
      "", 10, null, 0.0, genericProcess);

  static const STORE = const Building("--", const [70.0], const [Resource.MONEY], "bld_07",
      "", 2, null, 0.0, genericProcess);

  static const DORM = const Building("--", const [70,0], const [Resource.MONEY], "bld_08",
      "", 2, null, 0.0, genericProcess);

  static const TOOL_FACTORY = const Building("--", const [70.0], const [Resource.MONEY], "bld_09",
      "", 12, null, 0.0, genericProcess);

  static const FIELD_01 = const Building("--", const [70.0], const [Resource.MONEY], "bld_10",
      "", 4, null, 0.0, genericProcess);

  static const FIELD_02 = const Building("--", const [70.0], const [Resource.MONEY], "bld_11",
      "", 4, null, 0.0, genericProcess);

  int compareTo(Building p) {
    return (name).compareTo(p.name);
  }

  static void initBuildings() {
    for (int i = 0; i < Building.values.length; i++) {
     if (Building.values[i].htmlLabel.length > 0) {
       var a = querySelector("#" + Building.values[i].htmlLabel);
       a.innerHtml = Building.values[i].name;
     }
    }
  }

  bool isVisible() {
    String name = htmlStruct + "A";
    return !querySelector("#" + name).classes.contains("invisible");
  }
  
  void setVisible(bool visible) {
    if (htmlStruct.length < 1) {
      return;
    }
    for (int i = 0; i < rows; i++) {
      int c = "A".codeUnitAt(0) + i;
      String name = htmlStruct + new String.fromCharCode(c);
      gSetVisible(visible, name);
    }
  }
  
  void process(List<double> resource, List<ResourceResult> retVal) {
    processInternal(this, resource, retVal);
  }

  bool enoughResources(List<double> resources) {
    for (int i = 0; i < cost.length; i++) {
      if (resources[costType[i].value] < cost[i]) {
        return false;
      }
    }
    return true;
  }
}

void factoryProcess(Building b, List<double> resources, List<ResourceResult> retVal) {
  double workerCount = resources[Resource.FACTORY_WORKERS.value];
  double supply = resources[b.costType[0].value];
  double limit = (supply ~/ b.cost[0]).toDouble();
  double min;
  if (limit < workerCount) {
    min = limit;    
  } else {
    min = workerCount;
  }
  
  if (limit > workerCount && resources[Resource.STUDENTS.value] > 0 &&
        Resource.FACTORY_WORKERS.withinLimit(workerCount + 1)) {
      retVal.add(new ResourceResult(Resource.FACTORY_WORKERS, 1.0));
      retVal.add(new ResourceResult(Resource.STUDENTS, -1.0));
      min++;
  }
  
  if (workerCount > 0) {
    b.setVisible(true);
  }

  double outputMulti = Building.TOOL_FACTORY.isVisible() ? 2.0 : 1.0;
  var vendAssembly = querySelector("#vend_assembly");
  if (!vendAssembly.checked) {
    outputMulti *= -1.0;
  }

  if (min > 0) {
    retVal.add(new ResourceResult(b.costType[0], -b.cost[0] * min));
    retVal.add(new ResourceResult(b.outputType, b.outputAmount * min * outputMulti));
  }
}

void depotProcess(Building b, List<double> resources, List<ResourceResult> retVal) {
  b.setVisible(true);
  double colonies = resources[Resource.COLONIES.value];
  if (b.enoughResources(resources)) {
    for (int i = 0; i < b.cost.length; i++) {
      retVal.add(new ResourceResult(b.costType[i], -b.cost[i]));
    }
    retVal.add(new ResourceResult(Resource.COLONIES, 1.0));
    colonies++;
  }
  if (colonies > 0) {
    var cnt = querySelector("#depot_count");
    String display = "@" + colonies.toInt().toString();
    while (display.length < 5) {
      display += "_";
    }
    cnt.innerHtml = display;
  }
}

void schoolProcess(Building b, List<double> resources, List<ResourceResult> retVal) {
  genericProcess(b, resources, retVal);
  // the school loses an accumulated student if funding is cut
  if (resources[b.outputType.value] > 0 &&
      resources[b.costType[0].value] < b.cost[0] &&
      !Player.clampedStudents) {
    retVal.add(new ResourceResult(b.outputType, -1.0));
  }
}

void genericProcess(Building b, List<double> resources, List<ResourceResult> retVal) {
  if (b.costType == null || b.outputType == null) {
    return;
  }
  if (b.enoughResources(resources)) {
    retVal.add(new ResourceResult(b.costType[0], -b.cost[0]));
    if (b.outputType.withinLimit(resources[b.outputType.value] + b.outputAmount)) {
      retVal.add(new ResourceResult(b.outputType, b.outputAmount));
    }
    b.setVisible(true);
  }
  if (b.htmlLabel.length > 0) {
    var build = querySelector("#" + b.htmlLabel);
    if (resources[b.outputType.value] > 0) {
      build.classes.remove("broken");
    } else {
      build.classes.add("broken");
    }
  }
}
