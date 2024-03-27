import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'brocode.dart';

void main() {
  runApp(
      const GameWidget<Brocode>.controlled(
        gameFactory: Brocode.new,
      )
  );
}