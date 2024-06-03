
import 'dart:async';

import 'package:brocode/core/lobbies/lobby_player.dart';

import '../../game/brocode.dart';
import '../lobbies/lobby.dart';
import '../utils/server_util.dart';

/// Handles all event related to the lobby <br>
/// This class is a singleton, it's instance can be accessed either by the constructor or by the static getter "instance".
class LobbyService {
  static final LobbyService _instance = LobbyService._internal();
  static LobbyService get instance => _instance;

  factory LobbyService() {
    return _instance;
  }
  LobbyService._internal();

  Lobby? lobby;
  LobbyPlayer? player;
  Brocode? _game;
  bool get isLobbyOwner => lobby != null ? lobby!.getLobbyOwner().id == player!.id : false;

  /// A list of all players in the lobby (AFK included) (empty when not connected to a lobby)
  List<LobbyPlayer> get playersInLobby => lobby == null ? [] : lobby!.players.toList();

  Future<Lobby?> createLobby(String lobbyName, String playerName) async {
    final lobby = await ServerUtil.createLobby(lobbyName, playerName);
    if(lobby != null) {
      this.lobby = lobby;
      player = this.lobby!.players[0];
    }
    return lobby;
  }

  /// Tries to join a lobby, a lobby owner can't join another lobby. <br>
  /// lobbyId: The id of the lobby to join
  Future<Lobby?> joinLobby(String lobbyId, String playerName) async {
    if(isLobbyOwner) {
      return null;
    }
    final (lobby, player) = await ServerUtil.joinLobby(lobbyId, playerName);
    if(lobby != null && player != null) {
      this.lobby = lobby;
      this.player = player;
    }
    return lobby;
  }

  Future<Lobby?> getLobby() async {
    if(this.lobby == null) {
      return null;
    }
    final lobby = await ServerUtil.getLobby(this.lobby!.id);
    if(lobby == null) { // lobby was deleted
      this.lobby = null;
      player = null;
      return null;
    }
    return this.lobby!.updateWithLobby(lobby);
  }

  Future updatePlayer(LobbyPlayer player) async {
    if(lobby == null) {
      return;
    }
    return await ServerUtil.updatePlayerInLobby(lobby!.id, player);
  }

  Future leaveLobby() async {
    if(lobby == null) {
      return false;
    }
    if(await ServerUtil.leaveLobby(lobby!.id, player!.id.toString())) {
      lobby!.playerLeave(player!.id); // set player as "left"

      if(lobby!.activePlayer.isEmpty) {
        ServerUtil.deleteLobby(lobby!.id);
      }
    }
    lobby = null;
    player = null;
  }

  void startGame() {
    //_game = game;
    if(lobby == null) {
      return;
    }
    lobby!.startGame();
    ServerUtil.startGame(lobby!.id);
  }
}