import 'dart:async';

import 'package:brocode/brocode.dart';
import 'package:brocode/objects/ground_block.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class GameMap extends PositionComponent with HasGameReference<Brocode> {
  static const double scaleFactor = 2;
  late TiledComponent mapComponent;
  late List<GroundBlock> blocks = [];

  @override
  FutureOr<void> onLoad() async {
    mapComponent = await TiledComponent.load("simple_map_1.tmx", Vector2.all(8 * scaleFactor));
    mapComponent.anchor = Anchor.topLeft;
    mapComponent.position = Vector2.zero();

    final collisions = mapComponent.tileMap.getLayer<ObjectGroup>('Collisions');
    if(collisions != null){
      for (final collision in collisions.objects){
        // creating a separate object with its own hitbox is needed
        // because Flame merge all the added hitbox into a single PolygonHitbox
        final groundBlock = GroundBlock(collision, scaleFactor);
        blocks.add(groundBlock);
      }
    }

    addAll([mapComponent, ...blocks]);

    return super.onLoad();
  }
}