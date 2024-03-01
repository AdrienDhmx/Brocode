import 'dart:async';

import 'package:brocode/brocode.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Map extends PositionComponent with HasGameRef<Brocode>{
  late TiledComponent mapComponent;

  @override
  FutureOr<void> onLoad() async {
    mapComponent = await TiledComponent.load("simple_map_1.tmx", Vector2.all(16));
    mapComponent.anchor = Anchor.center;
    mapComponent.position = getMapPosition(game.canvasSize);

    final collisions = mapComponent.tileMap.getLayer<ObjectGroup>('collisions');

    if(collisions != null){
      for (final collision in collisions.objects){
        add(RectangleHitbox(
          size: collision.size,
          position: collision.position,
        ));
      }
    }

    add(mapComponent);
    return super.onLoad();
  }

  Vector2 getMapPosition(Vector2 canvasSize) {
    // 750 fix the ground at the same height (from bottom of window) no matter the screen size
    return Vector2(canvasSize.x / 2, canvasSize.y - 750);
  }
  @override
  void onGameResize(size) {
    super.onGameResize(size);
    if(isLoaded) {
      mapComponent.position = getMapPosition(size);
    }
  }
}