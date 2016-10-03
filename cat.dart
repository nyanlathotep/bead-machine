part of gamesystem;

class Cat {
  static final String ART =
      "      Cat   \n" 
      "  ^^        \n"                             
      " (ºº)_____    \n"       
      "  \\_______│~~~\n"   
      "    │└  │└  \n";
  
  bool visible = false;
  static int statementCount = 0;

  Map toJson() {
    Map map = new Map();
    map["visible"] = visible;
    map["statementCount"] = statementCount;
    return map;
  }
  
  void load(Map map) {
    setVisible(map["visible"]);
    statementCount = map["statementCount"];
  }
  
  void setVisible(bool v) {
    visible = v;
    gSetVisible(v, "cat");
  }
  
  void show() {
    var cat;
    cat = querySelector("#cat");
    cat.innerHtml = gAsciiArt(ART);
    cat.onClick.listen((e) => makeTheCatTalk());
  }
    
  void makeTheCatTalk() {

    switch(statementCount) {
      case 0:
        talk("hi");
        break;
      case 1:
        talk("hello");
        break;
      case 2:
        talk("stop");
        break;
      case 3:
        talk("meow...");
        break;
      case 25:
        talk("mew");
        break;
      case 26:
        talk("Multiplying two negatives makes a positive.");
        break;
      case 50:
        talk("prrrrr");
        break;
      default:
        talk("bingo");
        break;
    }
    statementCount++;
  }
  
  void talk(String message) {
    var cat = querySelector ("#cat_talk");
    cat.text = message;
  }
}
