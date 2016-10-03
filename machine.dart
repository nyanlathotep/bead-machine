part of gamesystem;

class PartAndLabel {
  Part part;
  var label;

  PartAndLabel(this.part, this.label);

  bool isTangible() {
    return !label.classes.contains("intangible");
  }
}

class Machine {

  static bool infinite = false;
  static const MAX_GRID_X = 8;
  static const MAX_GRID_Y = 8;
  static int GRID_X = infinite ? 8 : 5;
  static int GRID_Y = infinite ? 8 : 5;
  List parts = new List(MAX_GRID_X * MAX_GRID_Y);
  PartAndLabel selected;
  bool brokenArrow = false;
  List<PartAndLabel> partAndLabelList = new List();

  Machine() {
    if (infinite) {
      initList(Part.values);
    }
  }

  Map toJson() {
    Map map = new Map();
    map["parts"] = parts;
    map["gsx"] = GRID_X;
    map["gsy"] = GRID_Y;
    return map;
  }

  void load(Map map) {
    List savedparts = map["parts"];
    GRID_X = map["gsx"];
    GRID_Y = map["gsy"];
    if (GRID_X == 0 || GRID_X == null) {
      GRID_X = 5;
    }
    if (GRID_Y == 0 || GRID_Y == null) {
      GRID_Y = 5;
    }

    this.clear();
    this.createGrid();

    for (int i = 0; i < savedparts.length; i++) {
      int x = i % GRID_X;
      int y = i ~/ GRID_Y;
      Part p = Part.load(savedparts[i]);
      if (p != null) {
        getMachineCell(x, y).innerHtml = p.toHtml();
        setPart(x, y, p);
      }
    }
    matchPartsToList();
  }

  void initList(List<Part> partList) {
    partList.sort((e1, e2) => e1.compareTo(e2));
    var listContainer = querySelector("#part_list");
    StringBuffer buffer = new StringBuffer();
    String bar = "+--------------------+";
    buffer.write(bar + "<br>");
    int i = 0;
    for (Part p in partList) {
      String name = "|" + p.name + ": " + p.display;
      while (name.length < bar.length - 1) {
        name += " ";
      }
      name += "|";
      buffer.write("<span draggable=true id='list_" + (i++).toString() + "'>" +
          gAsciiArt(name) + "<br></span>");
    }
    buffer.write(bar + "<br>");
    listContainer.innerHtml = buffer.toString();
    partAndLabelList.clear();
    for (int j = 0; j < i; j++) {
      var label = querySelector("#list_" + j.toString());
      Part part = partList[j];
      partAndLabelList.add(new PartAndLabel(part, label));
      label.onMouseDown.listen((e) => clickList(j, part));
    }

    // match parts to list
    matchPartsToList();
  }

  void matchPartsToList() {
    // match parts to list
    for (int i = 0; i < GRID_X; i++) {
      for (int j = 0; j < GRID_Y; j++) {
        Part p = getPart(i, j);
        if (p != null) {
          for (int k = 0; k < partAndLabelList.length; k++) {
            if (partAndLabelList[k].part == p && partAndLabelList[k].isTangible(
                )) {
              partAndLabelList[k].label.classes.add("intangible");
              break;
            }
          }
        }
      }
    }
  }

  Part getPart(int i, int j) {
    if (i >= GRID_X || j >= GRID_Y || i < 0 || j < 0) {
      return null;
    }
    return parts[i + j * GRID_X];
  }

  void setPart(int i, int j, Part p) {
    parts[i + j * GRID_Y] = p;
  }

  static String genCellName(int i, int j) {
    return "square" + i.toString() + "_" + j.toString();
  }

  bool empty = false;

  // Returns a list of pairs (i.e. lists) of (Resource+Amount)
  List<List> processNodeInternal(int x, int y, Resource r, double amount, Dir
      from) {
    Part p = getPart(x, y);
    if (p != null) {
      empty = false;
      List<PartResults> partResults = p.process(r, amount, from);
      List retVal = new List();
      for (PartResults result in partResults) {
        int x2 = x;
        int y2 = y;
        switch (result.direction) {
          case Dir.RT:
            x2++;
            break;
          case Dir.LT:
            x2--;
            break;
          case Dir.UP:
            y2--;
            break;
          case Dir.DN:
            y2++;
            break;
        }
        var output = processNodeInternal(x2, y2, result.resource, result.amount,
            result.direction.opposite());

        if (p.name == "Hopper" || p.name == "Coiler") {
            showAnim(x, y, result.direction.opposite(), p.accept[0], -p.requires, p, false);
        }

        if (empty) {
          empty = false;
          showAnim(x, y, result.direction, result.resource, result.amount, p,
              true);
        }

        if (output.isEmpty) {
          brokenArrow = true;
          getMachineCellArrow(x, y, result.direction).classes.add("broken");
        } else {
          getMachineCellArrow(x, y, result.direction).classes.remove("broken");
        }
        // after returning a result, add a + animation over the arrow?
        retVal.addAll(output);
      }
      return retVal;
    }
    empty = true;
    return [[r, amount]];
  }

  void showAnim(int x, int y, Dir direction, Resource resource, double
      amount, Part p, bool up) {

    var radios = querySelectorAll("[name='machine_viz']");
    for (var el in radios) {
      String b = el.value;
      if (b == "on") {
        if (!el.checked) {
          return;
        }
        break;
      }
    }
    
    var curSquare = getMachineCellArrow(x, y, direction);
    //print("+++Show $x $y -> " + direction.name + ": $amount");
    curSquare.innerHtml = p.getIconForDirection(direction) + "<div class='" +
        (up ? "pop" : "drop") + "Anim'>" + Shop.printableResourceAmount(resource, amount
        ) + "</div>";
  }

  Element getMachineCellArrow(int x, int y, Dir direction) => getMachineCell(x,
      y).querySelector("#" + direction.name + "_arrow");

  Element getMachineCell(int x, int y) => querySelector("#" + genCellName(x, y)
      );

  // Returns a list of pairs (i.e. lists) of (Resource+Amount)
  List<List> process(List<double> resources, Resource r, double amount) {
    brokenArrow = false;
    List<double> rList = new List();
    // copy that we modify as we go to ensure we don't overspend
    rList.addAll(resources);
    rList[r.value] += amount;
    // Start with the assumption that we've already earned the passed in resource

    //for ( PartAndLabel p in  partAndLabelList ) {
    //  print(p.label.id + " " + p.label.classes.toString());
    //}

    // Process Hoppers
    List retVal = new List();
    retVal.add([r, amount]);
    for (int i = 0; i < GRID_X; i++) {
      for (int j = 0; j < GRID_Y; j++) {
        Part p = getPart(i, j);
        // Hopper: pull something out of the inventory and feed that in.
        if (p != null && p.inConnections.isEmpty) {
          for (Resource accept in p.accept) {
            if (rList[accept.value] >= p.requires) {
              rList[accept.value] -= p.requires;
              retVal.add([accept, -p.requires]);
              retVal.addAll(processNodeInternal(i, j, accept, p.requires, null)
                  ); // null because it comes from the inventory.
              break;
            }
          }
        }
      }
    }
    return retVal;
  }

  // TODO: Just one entry for each unique part type

  //  **** CLICK HANDLERS ****
  void clickList(int index, Part p) {
    for (int i = 0; i < partAndLabelList.length; i++) {
      PartAndLabel pal = partAndLabelList[i];
      var label = pal.label;
      if (i == index) {
        label.classes.add("active");
        selected = pal;
      } else {
        label.classes.remove("active");
      }
    }
  }

  void clickCell(var target, int x, int y) {
    String id = target.id;
    Part nextPart = null;
    Part currentPart = getPart(x, y);
    if (currentPart == null) {
      if (selected == null) {
        return;
      }
      nextPart = selected.part;
      target.innerHtml = nextPart.toHtml();
      if (!infinite) {
        selected.label.classes.add("intangible");
        selected.label.classes.remove("active");
        selected = null;
      }
      setPart(x, y, nextPart);
    } else {
      removePartInternal(currentPart, target, x, y);
    }
  }

  void removePart(int x, int y) {
    Part currentPart = getPart(x, y);
    var target = getMachineCell(x, y);
    if (target != null) {
      removePartInternal(currentPart, target, x, y);
    }
  }

  void removePartInternal(Part currentPart, target, int x, int y) {
    for (PartAndLabel pal in partAndLabelList) {
      if (pal.part == currentPart && !pal.isTangible()) {
        pal.label.classes.remove("intangible");
        break;
      }
    }
    target.innerHtml = "";
    setPart(x, y, null);
  }

  void dropOnCell(var target, int x, int y) {
    if (getPart(x, y) != null) {
      clickCell(target, x, y);
    }
    clickCell(target, x, y);
  }

  // **** DISPLAY ****
  void show() {
    createGrid();
  }

  void createGrid() {
    var grid = querySelector("#machine_grid");
    StringBuffer buffer = new StringBuffer();
    buffer.write("<table border='1' cellpadding='0' cellspacing='0'>");
    for (int j = 0; j < GRID_Y; j++) {
      buffer.write("<tr>");
      for (int i = 0; i < GRID_X; i++) {
        buffer.write("<td height=100 width=115 id='" + genCellName(i, j) +
            "'>&nbsp;</td>");
      }
      buffer.write("</tr>");
    }
    buffer.write("</table>");
    grid..innerHtml = buffer.toString();
    for (int j = 0; j < GRID_Y; j++) {
      for (int i = 0; i < GRID_X; i++) {
        Element cell = getMachineCell(i, j);
        cell
            ..onClick.listen((e) => clickCell(cell, i, j))
            ..dropzone = "true"
            ..onDragOver.listen((e) => e.preventDefault())
            ..onDrop.listen((e) => dropOnCell(cell, i, j));
      }
    }
  }

  void clear() {
    for (int i = 0; i < GRID_X; i++) {
      for (int j = 0; j < GRID_Y; j++) {
        removePart(i, j);
      }
    }
  }
}
