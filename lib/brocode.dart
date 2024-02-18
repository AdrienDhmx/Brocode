

import 'dart:async';
import 'dart:ui';

import 'package:brocode/player.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class Brocode extends FlameGame with HasKeyboardHandlerComponents{
  @override
  FutureOr<void> onLoad() {
    final player = Player(color: "Blue");
    add(player);
    return super.onLoad();
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }
}