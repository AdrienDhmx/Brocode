import 'dart:async';
import 'dart:ui';

import 'package:brocode/game/brocode.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'objects/ground_block.dart';

class GameMap extends PositionComponent with HasGameReference<Brocode> {
  static const double scaleFactor = 3;
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

    // render the map as a single image instead of a TiledComponent to improve performance
    // and avoid the weird rendering of the map on some frames
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    mapComponent.tileMap.render(canvas);
    final picture = recorder.endRecording();

    final imageWidth = (mapComponent.tileMap.map.width * mapComponent.tileMap.map.tileWidth * scaleFactor).round();
    final imageHeight = (mapComponent.tileMap.map.height * mapComponent.tileMap.map.tileHeight * scaleFactor).round();
    final image = await picture.toImage(imageWidth, imageHeight);
    final mapSprite = SpriteComponent(
      sprite: Sprite(image),
      paint: Paint(),
      position: mapComponent.position,
      scale: mapComponent.scale,
      anchor: mapComponent.anchor,
    );

    addAll([mapSprite, ...blocks]);

    return super.onLoad();
  }
}