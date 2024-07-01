import 'dart:async';
import 'package:brocode/game/player.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:brocode/game/game_map.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:brocode/game/objects/lifeheart.dart';
import '../app/screens/game.dart';
import '../core/services/lobby_service.dart';
import '../core/utils/platform_utils.dart';
import '../core/utils/print_utils.dart';
import 'objects/magazine.dart';
import 'package:flame_audio/flame_audio.dart';


class Brocode extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, PanDetector, PointerMoveCallbacks  {
  late MyPlayer player;
  late List<OtherPlayer> otherPlayers = [];
  late GameMap map;
  Vector2 cursorPosition = Vector2.zero();
  final double positionGapResistance = 50;
  late bool _isPauseMenuOpen = false;
  late Vector2 cameraVerticalOffset;

  final List<String> gameImages = const [
    'bullet_sprites/Bullet.png',
    'others/crosshair010.png',
    'others/red_crosshair.png',
    'character_sprites/Green/Gunner_Green_Shoot.png',
    'others/heart.png'
  ];

  @override
  FutureOr<void> onLoad() async {
    await images.loadAll(gameImages);
    await FlameAudio.audioCache.load('shot_sound.mp3');

    mouseCursor = flutter_material.SystemMouseCursors.none;

    add(camera..priority=1);

    // HUD
    final magazine = ImageMagazine();
    final lifeheart = ImageLifeheart();
    add(lifeheart..priority=1);
    add(magazine..priority=1);

    // Map
    map = GameMap();
    world.add(map);
    await map.loaded;

    // Players
    if(LobbyService.instance.lobby != null) {
      final availableColorsForOthers = PlayerColors.values.toList();
      final availableSpawns = map.spawnPoints.toList();
      for (var playerInLobby in LobbyService().playersInLobby) {
        final colorIndex = playerInLobby.id % availableColorsForOthers.length;
        final spawnIndex = playerInLobby.id % availableSpawns.length;
        final PlayerColors color = availableColorsForOthers[colorIndex];
        final Vector2 spawnPos = availableSpawns[spawnIndex].position * GameMap.scaleFactor;
        if(playerInLobby.id == LobbyService().player?.id) {
          player = MyPlayer(id: playerInLobby.id, color: color, pseudo: playerInLobby.name, spawnPos: spawnPos);
        } else {
          otherPlayers.add(OtherPlayer(id: playerInLobby.id, color: color, pseudo: playerInLobby.name, spawnPos: spawnPos));
        }
      }
    } else { // solo mode
      player = MyPlayer(id: 0, color: PlayerColors.green, pseudo: "Joueur 1", spawnPos: map.spawnPoints[0].position * GameMap.scaleFactor);
    }

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
      cursorPosition = size; //player starts the game looking to the right.
    }

    //debugMode = true;
    world.addAll([
      player,
      ...otherPlayers,
    ]);

    await player.loaded;
    if(otherPlayers.isNotEmpty) {
      await otherPlayers.last.loaded;
    }

    camera.follow(player, snap: true);

    // add(FpsTextComponent(position: Vector2(0, size.y - 24)));
    // uncomment to print all the components in the world
    //printChildren(this);

    return super.onLoad();
  }

  @override
  flutter_material.KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    final isKeyDown = event is KeyDownEvent;

    final isEscape = keysPressed.contains(LogicalKeyboardKey.escape);
    if(isKeyDown && isEscape) {
      _isPauseMenuOpen ? closePauseMenu() : openPauseMenu();
      return flutter_material.KeyEventResult.handled;
    }

    return flutter_material.KeyEventResult.ignored;
  }

  @override
  void update(dt) {
    Vector2 playerShotDirection = player.shotDirection.clone();
    double maxRange = player.weaponRange * player.scale.y;
    double ratio = playerShotDirection.length > maxRange? maxRange: playerShotDirection.length;
    ratio /= maxRange;
    cameraVerticalOffset = playerShotDirection.normalized() * ratio * 100;
    camera.viewport.position = -cameraVerticalOffset;
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
          //redécalage de la position du joueur si elle est trop décalée par rapport à celle enregistrée sur le serveur
          if(playerInLobby.position != null && (playerInLobby.position! - otherPlayer.position).length > positionGapResistance ){
            otherPlayer.position = playerInLobby.position!;
          }
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

  void openPauseMenu() {
    mouseCursor = SystemMouseCursors.basic;
    overlays.remove(Overlays.pauseButton.name);
    overlays.add(Overlays.pause.name);
    _isPauseMenuOpen = true;
  }

  void closePauseMenu() {
    mouseCursor = SystemMouseCursors.none;
    overlays.remove(Overlays.pause.name);
    overlays.add(Overlays.pauseButton.name);
    _isPauseMenuOpen = false;
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }
}