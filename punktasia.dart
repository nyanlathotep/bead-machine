library punktasia;

import 'dart:async';
import 'gamesystem.dart';

GameSystem game = new GameSystem();
const oneSecond = const Duration(seconds: 1);

void main() {
  game.gainFunc(null);
  new Timer.periodic(oneSecond, game.gainFunc);
}
