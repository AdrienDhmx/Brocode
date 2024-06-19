import 'dart:async';
import 'package:brocode/game/player.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:brocode/game/game_map.dart';
import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter/widgets.dart' as widgets;
import 'package:go_router/go_router.dart';
import 'package:brocode/game/objects/lifeheart.dart';
import '../app/router.dart';
import '../core/services/lobby_service.dart';
import '../core/utils/platform_utils.dart';
import '../core/utils/print_utils.dart';
import 'objects/magazine.dart';


class Brocode extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, PanDetector, PointerMoveCallbacks  {
  late MyPlayer player;
  late List<OtherPlayer> otherPlayers = [];
  Vector2 cursorPosition = Vector2.zero();
  bool previousQueryCompleted = true;
  int queryErrorInARowCount = 0;

  @override
  FutureOr<void> onLoad() async {
    await images.load('bullet_sprites/Bullet.png');
    await images.load('others/crosshair010.png');
    await images.load('others/red_crosshair.png');
    await images.load('character_sprites/Green/Gunner_Green_Shoot.png');
    await images.load('others/heart.png');
    final map = GameMap();

    if(LobbyService.instance.lobby != null) {
      final availableColorsForOthers = PlayerColors.values.toList();
      for (var playerInLobby in LobbyService().playersInLobby) {
        if(playerInLobby.id == LobbyService().player?.id) {
          final colorIndex = playerInLobby.id % availableColorsForOthers.length;
          player = MyPlayer(id: playerInLobby.id, color: availableColorsForOthers[colorIndex], pseudo: playerInLobby.name);
        } else {
          final colorIndex = playerInLobby.id % availableColorsForOthers.length;
          PlayerColors color = availableColorsForOthers[colorIndex];
          otherPlayers.add(OtherPlayer(id: playerInLobby.id, color: color, pseudo: playerInLobby.name));
        }
      }
    } else { // solo mode
      player = MyPlayer(id: 0, color: PlayerColors.green, pseudo: "Joueur 1");
    }

    mouseCursor = flutter_material.SystemMouseCursors.none;

    if(isOnPhone()) {
      const cameraVerticalOffset = 50;
      camera.viewport.position.y += cameraVerticalOffset;
      camera.viewfinder.zoom = 0.75;

      // add the joysticks
      final movementJoystick = createVirtualJoystick(flutter_material.Colors.white,
          margin: const flutter_material.EdgeInsets.only(left: 50, bottom: cameraVerticalOffset + 40));
      final shootJoystick = createVirtualJoystick(flutter_material.Colors.white,
          margin: const flutter_material.EdgeInsets.only(right: 50, bottom: cameraVerticalOffset + 40));

      camera.viewport.add(movementJoystick);
      camera.viewport.add(shootJoystick);

      player.movementJoystick = movementJoystick;
      player.shootJoystick = shootJoystick;
    } else {
      // will place the player at 1/4 of the height of the screen from the bottom
      final cameraVerticalOffset = camera.viewport.size.y / 4;
      camera.viewport.position.y += cameraVerticalOffset;
      cursorPosition = size; //player starts the game looking to the right.
    }
    add(camera..priority=1);
    final magazine = ImageMagazine();
    final lifeheart = ImageLifeheart();
    add(lifeheart..priority=1);
    add(magazine..priority=1);
    //debugMode = true;
    world.addAll([
      map,
      player,
      ...otherPlayers,
    ]);
    camera.follow(player, snap: true);

    // add(FpsTextComponent(position: Vector2(0, size.y - 24)));
    // uncomment to print all the components in the world
    await map.loaded;
    //printChildren(this);

    return super.onLoad();
  }

  @override
  void update(dt) {
    if(otherPlayers.isNotEmpty) {
      final lobby = LobbyService().lobby;
      if(lobby != null) {
        for (final playerInLobby in lobby.players) {
          if(playerInLobby.id == player.id) {
            continue;
          }

          final otherPlayer = otherPlayers.firstWhere((p) => p.id == playerInLobby.id);
          otherPlayer.horizontalDirection = playerInLobby.horizontalDirection.toInt();
          otherPlayer.hasJumped = playerInLobby.hasJumped;
          otherPlayer.setShotDirection(playerInLobby.aimDirection!);
          otherPlayer.isShooting = playerInLobby.hasShot;
          otherPlayer.healthBar.healthPoints = playerInLobby.healthPoints;
          otherPlayer.isReloading = playerInLobby.isReloading;
          otherPlayer.isDead = playerInLobby.isDead;
        }
      }
    }
    super.update(dt);
  }

  @override
  void onPanStart(DragStartInfo info) {
    if(isOnPhone()) {
      return;
    }
    player.isShooting = true;
    cursorPosition = info.raw.globalPosition.toVector2();
  }
  @override
  void onPanUpdate(DragUpdateInfo info) {
    cursorPosition = info.raw.globalPosition.toVector2();
    super.onPanUpdate(info);
  }
  @override
  void onPanEnd(DragEndInfo info) {
    if(isOnPhone()) {
      return;
    }
    player.isShooting = false;
  }
  @override
  void onPointerMove(PointerMoveEvent event) {
    cursorPosition = event.localPosition;
    super.onPointerMove(event);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }
}