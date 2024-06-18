import 'dart:convert';

import 'package:brocode/core/lobbies/lobby_player.dart';
import 'package:equatable/equatable.dart';

enum LobbyStatus {
  waiting,
  inGame,
  over,
}

class Lobby extends Equatable {
  const Lobby({required this.name, required this.id, this.status = LobbyStatus.waiting, this.players = const [], this.startTime = 0});

  final String name;
  final String id;

  final LobbyStatus status;
  bool get isWaiting => status == LobbyStatus.waiting;

  final int startTime;

  final List<LobbyPlayer> players;
  List<LobbyPlayer> get activePlayers => players.where((p) => !p.isAFK && !p.hasLeft).toList();

  /// Get the first player that's not AFK
  LobbyPlayer getLobbyOwner() {
    return players.firstWhere((p) => !p.isAFK);
  }

  LobbyPlayer? getPlayer(int playerId) {
    if(playerId < 0 || playerId > players.length - 1) {
      return null;
    }
    return players[playerId];
  }

  /// set the player property hasLeft to true
  void playerLeaving(int playerId) {
    final player = getPlayer(playerId);
    if(player != null) {
      players[playerId] = LobbyPlayer.copyWith(player, hasLeft: true);
    }
  }

  static Lobby fromJson(Map<String, dynamic> json, {bool summary = false, playerSummary = false}) {
    final id = json["id"];
    final name = json["name"];
    final status = int.tryParse(json["lobbyStatus"]?.toString() ?? '');
    final startTime = int.tryParse(json["startTime"]?.toString() ?? '');

    if(id == null || name == null || status == null || startTime == null) {
      throw ArgumentError("[BROCODE] Id, name, startTime or status missing to create a lobby");
    }

    if(summary) {
      final owner = json["owner"];
      if(owner == null) {
        throw ArgumentError("[BROCODE] The owner of the lobby is required.");
      }

      final player = LobbyPlayer.fromJson(owner, summary: true);
      return Lobby(id: id, name: name, status: LobbyStatus.values[status], players: [player], startTime: startTime);
    } else {
      final playersJson = json["players"];

      final players = <LobbyPlayer>[];
      if(playersJson is Iterable) {
        for (var playerJson in playersJson) {
          final player = LobbyPlayer.fromJson(playerJson, summary: playerSummary);
          players.add(player);
        }
        return Lobby(id: id, name: name, status: LobbyStatus.values[status], players: players, startTime: startTime);
      }
      return Lobby(id: id, name: name, status: LobbyStatus.values[status], startTime: startTime);
    }
  }

  Map<String, dynamic> toJson({bool summary = false, bool playerSummary = false}) {
    final defaultJson = {
      "id": id,
      "name": name,
      "status": status.name,
    };

    if(summary) {
      return {
        ...defaultJson,
        "owner": players[0].toJson(summary: true),
        "playerCount": activePlayers.length,
      };
    }

    return {
      ...defaultJson,
      "players": [
        ...players.map((player) => player.toJson(summary: playerSummary))
      ],
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  @override
  List<Object?> get props => [id, name, status, startTime, players, activePlayers];
}