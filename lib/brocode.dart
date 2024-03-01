import 'dart:async';
import 'dart:ui';

import 'package:brocode/player.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:brocode/map.dart';

class Brocode extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection{

  @override
  FutureOr<void> onLoad() async {
    final map = Map();
    final player = Player(color: "Blue");
    world.addAll([
      map,
      player,
    ]);
    add(world);
    camera.follow(player);
    return super.onLoad();
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }
}