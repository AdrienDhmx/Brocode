import 'dart:async';
import 'dart:ui';

import 'package:brocode/player.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Brocode extends FlameGame with HasKeyboardHandlerComponents{
  late TiledComponent mapComponent;

  @override
  FutureOr<void> onLoad() async {
    await loadMap();
    final player = Player(color: "Blue");
    add(player);
    return super.onLoad();
  }

  Future<void> loadMap() async {
    // I set the tile size to 16 (instead of 8) to scale the map by 2, otherwise the tiles are too small
    mapComponent = await TiledComponent.load("simple_map_1.tmx", Vector2.all(16));
    mapComponent.anchor = Anchor.center;
    mapComponent.position = getMapPosition(canvasSize);
    add(mapComponent);
  }

  @override
  void onGameResize(size) {
    super.onGameResize(size);
    if(isLoaded) {
      mapComponent.position = getMapPosition(size);
    }
  }

  Vector2 getMapPosition(Vector2 canvasSize) {
    // 750 fix the ground at the same height (from bottom of window) no matter the screen size
    return Vector2(canvasSize.x / 2, canvasSize.y - 750);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }
}