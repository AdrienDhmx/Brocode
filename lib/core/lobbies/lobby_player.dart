
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flame/extensions.dart';

class LobbyPlayer extends Equatable {
  const LobbyPlayer({required this.name, required this.id, this.isAFK = false, this.hasLeft = false,
      this.hasShot = false, this.hasJumped = false, this.isReloading = false, this.horizontalDirection = 0.0,
      this.healthPoints = 100, this.aimDirection,
  });

  final String name;
  final int id;

  final bool isAFK;
  final bool hasLeft;

  final bool hasShot;
  final bool hasJumped;
  final bool isReloading;
  final Vector2? aimDirection;
  final double horizontalDirection;
  final int healthPoints;

  factory LobbyPlayer.copyWith(LobbyPlayer player,{
      String? name,
      int? id,
      bool? isAFK,
      bool? hasLeft,
      int? healthPoints,
      bool? isReloading,
      bool? hasJumped,
      bool? hasShot,
      double? horizontalDirection,
      Vector2? aimDirection}) {
    return LobbyPlayer(name: name ?? player.name, id: id ?? player.id, isAFK: isAFK ?? player.isAFK, isReloading: isReloading ?? player.isReloading,
                        hasLeft: hasLeft ?? player.hasLeft, healthPoints: healthPoints ?? player.healthPoints, hasJumped: hasJumped ?? player.hasJumped,
                        hasShot: hasShot ?? player.hasShot, horizontalDirection: horizontalDirection ?? player.horizontalDirection, aimDirection: aimDirection ?? player.aimDirection
                      );
  }

  static LobbyPlayer fromJson(Map<String, dynamic> json, {bool summary = false}) {
    final id = json["id"];
    final name = json["name"];
    final isAFK = bool.tryParse(json["isAFK"]?.toString() ?? "");
    final hasLeft = bool.tryParse(json["hasLeft"]?.toString() ?? "");
    final healthPoints = int.tryParse(json["healthPoints"]?.toString() ?? "");
    final isReloading = bool.tryParse(json["isReloading"]?.toString() ?? "");
    final hasShot = bool.tryParse(json["hasShot"]?.toString() ?? "");
    final hasJumped = bool.tryParse(json["hasJumped"]?.toString() ?? "");
    final horizontalDirection = double.tryParse(json["horizontalDirection"]?.toString() ?? "");

    if(id == null || name == null || isAFK == null || hasLeft == null || healthPoints == null || isReloading == null
      || hasJumped == null || hasShot == null || horizontalDirection == null) {
      throw ArgumentError("[BROCODE] fields of players are missing or null");
    }

    final aimDirectionJson = json["aimDirection"];
    final aimDirectionX = double.tryParse(aimDirectionJson["x"]?.toString() ?? "");
    final aimDirectionY = double.tryParse(aimDirectionJson["y"]?.toString() ?? "");

    if(aimDirectionX == null || aimDirectionY == null) {
      throw ArgumentError("[BROCODE] aimDirection is missing or of incorrect type");
    }
    final aimDirection = Vector2(aimDirectionX, aimDirectionY);

    return LobbyPlayer(name: name, id: id, isAFK: isAFK, hasLeft: hasLeft, healthPoints: healthPoints, isReloading: isReloading,
      hasJumped: hasJumped, hasShot: hasShot, horizontalDirection: horizontalDirection, aimDirection: aimDirection,
    );
  }

  Map<String, dynamic> toJson({bool summary = false}) {
    final Map<String, dynamic> json = {
      "id": id.toString(),
      "name": name,
      "isAFK": isAFK.toString(),
      "hasLeft": hasLeft.toString(),
    };

    if (!summary) {
      json.addAll(getJsonPlayerState());
    }

    return json;
  }

  Map<String, dynamic> getJsonPlayerState() {
    return {
      "hasShot": hasShot.toString(),
      "hasJumped": hasJumped.toString(),
      "aimDirection": {
        "x": aimDirection?.x.toString(),
        "y": aimDirection?.y.toString(),
      },
      "horizontalDirection": horizontalDirection.toString(),
      "healthPoints": healthPoints.toString(),
      "isReloading": isReloading.toString(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  @override
  List<Object?> get props => [id, name, isAFK, hasLeft, horizontalDirection, aimDirection?.x, aimDirection?.y, hasJumped, hasShot, isReloading, healthPoints];
}