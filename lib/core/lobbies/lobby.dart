import 'dart:convert';

import 'package:brocode/core/lobbies/lobby_player.dart';

enum LobbyState {
  waiting,
  inGame,
  over,
}

class Lobby {
  Lobby({required this.name, required this.id});

  final String name;
  final String id;

  LobbyState state = LobbyState.waiting;
  bool get isWaiting => state == LobbyState.waiting;

  int startTime = 0;

  List<LobbyPlayer> players = [];
  List<LobbyPlayer> get activePlayer => players.where((p) => !p.isAFK && !p.hasLeft).toList();

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
  void playerLeave(int playerId) {
    getPlayer(playerId)?.leftLobby();
  }

  /// start the game for this lobby
  void startGame() {
    startTime = DateTime.now().millisecondsSinceEpoch;
    state = LobbyState.inGame;
  }

  Lobby updateWithLobby(Lobby lobby) {
    for (LobbyPlayer lobbyPlayer in lobby.players) {
      final player = getPlayer(lobbyPlayer.id);
      if(player != null) {
        player.updateFromPlayer(lobbyPlayer);
      } else {
        players.add(lobbyPlayer);
      }
    }

    if(lobby.players.length > players.length) {
      for(int i = players.length - 1; i < lobby.players.length; ++i) {
        players.add(lobby.players[i]);
      }
    }
    return this;
  }

  static Lobby fromJson(Map<String, dynamic> json, {bool summary = false, playerSummary = false}) {
    final id = json["id"];
    final name = json["name"];

    if(id == null || name == null) {
      throw ArgumentError("[BROCODE] Id or name missing to create a lobby");
    }

    final lobby = Lobby(id: id, name: name);

    if(summary) {
      final owner = json["owner"];
      if(owner == null) {
        throw ArgumentError("[BROCODE] The owner of the lobby is required.");
      }

      final player = LobbyPlayer.fromJson(owner, summary: true);
      lobby.players.add(player);
    } else {
      final playersJson = json["players"];

      if(playersJson is Iterable) {
        for (var playerJson in playersJson) {
          final player = LobbyPlayer.fromJson(playerJson, summary: playerSummary);
          lobby.players.add(player);
        }
      }
    }
    return lobby;
  }

  Map<String, dynamic> toJson({bool summary = false, bool playerSummary = false}) {
    final defaultJson = {
      "id": id,
      "name": name,
    };

    if(summary) {
      return {
        ...defaultJson,
        "owner": players[0].toJson(summary: true),
        "playerCount": activePlayer.length,
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
}