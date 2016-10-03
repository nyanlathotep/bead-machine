library resources;

import 'gamesystem.dart';

// Basically an enumeration
class Resource {
  static const MONEY = const Resource(0,"\$");
  static const FREE_LUNCHES = const Resource(1, "FL");
  static const BEADS = const Resource(2, "B");
  static const TRIANGLES = const Resource(3, "T");
  static const STUDENTS = const Resource(4, "S", 25.0);
  static const VENDING_MACHINES = const Resource(5, "V");
  static const FACTORY_WORKERS = const Resource(6, "W", 25.0);
  static const COILS = const Resource(7, "C");
  static const COLONIES = const Resource(8, "@");
  
  static const values = const [MONEY, FREE_LUNCHES, BEADS, TRIANGLES, STUDENTS,
                               VENDING_MACHINES, FACTORY_WORKERS, COILS, COLONIES];

  final int value;
  final double true_max;
  final String abbrv;

  double get max => (this == STUDENTS && Building.DORM.isVisible()) ? true_max * 2 : true_max;
  
  const Resource(this.value, this.abbrv, [this.true_max = -1.0]);
  
  bool withinLimit(double i) {
    return (i <= max || max == -1);
  }
  
  String toString() {
    return abbrv;
  }
}
