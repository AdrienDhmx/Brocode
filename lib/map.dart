import 'dart:async';

import 'package:brocode/brocode.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';

class Map extends PositionComponent with HasGameRef<Brocode> {
  static const double scaleFactor = 2;
  late TiledComponent mapComponent;

  @override
  FutureOr<void> onLoad() async {
    mapComponent = await TiledComponent.load("simple_map_1.tmx", Vector2.all(8 * scaleFactor));
    mapComponent.anchor = Anchor.topLeft;
    mapComponent.position = getMapPosition(game.canvasSize);

    final collisions = mapComponent.tileMap.getLayer<ObjectGroup>('Collisions');
    if(collisions != null){
      for (final collision in collisions.objects){
        add(RectangleHitbox(
          size: collision.size,
          position: collision.position * scaleFactor,
          anchor: Anchor.topLeft,
        ));
      }
    }

    add(mapComponent);
    return super.onLoad();
  }

  Vector2 getMapPosition(Vector2 canvasSize) {
    // 750 fix the ground at the same height (from bottom of window) no matter the screen size
    return Vector2(0, 0);
  }
  @override
  void onGameResize(size) {
    super.onGameResize(size);
    if(isLoaded) {
      mapComponent.position = getMapPosition(size);
    }
  }
}