import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:brocode/player.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:brocode/game_map.dart';
import 'package:flutter/material.dart';

class Brocode extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, PanDetector  {
  late Player player;

  @override
  FutureOr<void> onLoad() async {
    await images.load('bullet_sprites/Bullet.png');
    final map = GameMap();
    player = Player(color: "Blue");

    //debugMode = true;
    world.addAll([
      map,
      player,
    ]);

    final cameraVerticalOffset = camera.visibleWorldRect.height / 4;
    if(Platform.isAndroid || Platform.isIOS) {
      await Flame.device.setLandscape();

      if(Platform.isAndroid || Platform.isIOS) {
        final knobColor = Colors.white.withAlpha(220);
        Paint paint = Paint();
        paint.color = knobColor;
        final backgroundColor = Colors.white.withAlpha(100);
        Paint backgroundPaint = Paint();
        backgroundPaint.color = backgroundColor;
        final joystick = JoystickComponent(
          knob: CircleComponent(radius: 20, paint: paint),
          background: CircleComponent(radius: 50, paint: backgroundPaint),
          margin: EdgeInsets.only(left: 50, bottom: cameraVerticalOffset / 2),
        );
        camera.viewport.add(joystick);
        player.joystick = joystick;
      }
    } else {
      // will place the player at 1/4 of the height of the screen from the bottom
      camera.viewport.position.y += cameraVerticalOffset;
    }

    camera.follow(player, snap: true);

    // add(FpsTextComponent(position: Vector2(0, size.y - 24)));
    // uncomment to print all the components in the world
    // await map.loaded;
    // printChildren(world);

    return super.onLoad();
  }

  @override
  void onPanStart(DragStartInfo info) {
    player.isShooting = true;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    player.isShooting = false;
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }
}