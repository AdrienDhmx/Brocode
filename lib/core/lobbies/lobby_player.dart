
import 'dart:convert';

import 'package:flame/extensions.dart';

class LobbyPlayer {
  LobbyPlayer({required this.name, required this.id});
  final String name;
  final int id;

  bool isAFK = false;
  bool hasLeft = false;

  bool hasShot = false;
  bool hasJumped = false;
  Vector2 aimDirection = Vector2.zero();
  double horizontalDirection = 0.0;

  void setAFK() {
    isAFK = true;
  }

  void leftLobby() {
    hasLeft = true;
  }

  /// Update the player state
  void update(bool hasShot, bool hasJumped, Vector2 aimDirection, double horizontalDirection) {
    this.hasShot = hasShot;
    this.hasJumped = hasJumped;
    this.aimDirection = aimDirection;
    this.horizontalDirection = horizontalDirection;
  }

  void updateFromPlayer(LobbyPlayer player) {
    isAFK = player.isAFK;
    hasLeft = player.hasLeft;
    hasShot = player.hasShot;
    hasJumped = player.hasJumped;
    aimDirection = player.aimDirection;
    horizontalDirection = player.horizontalDirection;
  }

  /// Update the player from a Map
  void updateFromJson(Map<String, dynamic> json) {
    final hasShot = bool.tryParse(json["hasShot"]?.toString() ?? "");
    final hasJumped = bool.tryParse(json["hasJumped"]?.toString() ?? "");
    final horizontalDirection = double.tryParse(json["horizontalDirection"]?.toString() ?? "");

    final aimDirectionJson = json["aimDirection"];
    if(hasShot == null || hasJumped == null || horizontalDirection == null || aimDirectionJson == null) {
      throw ArgumentError("[BROCODE] hasShot, hasJumped or horizontalDirection are missing or not of the correct type");
    }
    final aimDirectionX = double.tryParse(aimDirectionJson["x"]?.toString() ?? "");
    final aimDirectionY = double.tryParse(aimDirectionJson["y"]?.toString() ?? "");

    if(aimDirectionX == null || aimDirectionY == null) {
      throw ArgumentError("[BROCODE] aimDirection is missing or of incorrect type");
    }

    final aimDirection = Vector2(aimDirectionX, aimDirectionY);
    update(hasShot, hasJumped, aimDirection, horizontalDirection);
    return;
  }

  static LobbyPlayer fromJson(Map<String, dynamic> json, {bool summary = false}) {
    final id = json["id"];
    final name = json["name"];
    final isAFK = bool.tryParse(json["isAFK"]?.toString() ?? "");
    final hasLeft = bool.tryParse(json["hasLeft"]?.toString() ?? "");

    if(id == null || name == null || isAFK == null || hasLeft == null) {
      throw ArgumentError("[BROCODE] id, name, isAFK or hasLeft are missing or not of the correct type");
    }

    LobbyPlayer player = LobbyPlayer(name: name, id: id);
    player.isAFK = isAFK;
    player.hasLeft = hasLeft;
    if (!summary) {
      player.updateFromJson(json);
    }
    return player;
  }

  Map<String, dynamic> toJson({bool summary = false}) {
    final Map<String, dynamic> json = {
      "id": id,
      "name": name,
      "isAFK": isAFK,
      "hasLeft": hasLeft,
    };

    if (!summary) {
      json.addAll(getJsonPlayerState());
    }

    return json;
  }

  Map<String, dynamic> getJsonPlayerState() {
    return {
      "hasShot": hasShot,
      "hasJumped": hasJumped,
      "aimDirection": {
        "x": aimDirection.x,
        "y": aimDirection.y,
      },
      "horizontalDirection": horizontalDirection,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}