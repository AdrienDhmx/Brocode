
import 'package:brocode/core/blocs/create_lobby/create_lobby_events.dart';
import 'package:brocode/core/blocs/fetch_lobbies/fetch_lobbies_events.dart';
import 'package:brocode/core/blocs/join_lobby/join_lobby_events.dart';
import 'package:brocode/core/lobbies/lobby_player.dart';
import 'package:brocode/core/services/bloc_service.dart';
import 'package:brocode/core/services/server_service.dart';

import '../lobbies/lobby.dart';


/// Handles all event related to the lobby <br>
/// This class is a singleton, it's instance can be accessed either by the constructor or by the static getter "instance".
class LobbyService {
  static final LobbyService _instance = LobbyService._internal();
  static LobbyService get instance => _instance;
  factory LobbyService() {
    return _instance;
  }
  LobbyService._internal() {
    _server.connectToServer();
  }

  late final ServerService _server = ServerService(handleMessage: handleMessage);

  Lobby? lobby;
  LobbyPlayer? player;
  bool get isLobbyOwner => lobby != null ? lobby!.getLobbyOwner().id == player!.id : false;

  /// A list of all players in the lobby (AFK included) (empty when not connected to a lobby)
  List<LobbyPlayer> get playersInLobby => lobby == null ? [] : lobby!.players.toList();

  void handleMessage(Map<String, dynamic> message) {
    final incomingEvent = IncomingServerEvents.values.firstWhere((e) => e.name == message['action'], orElse: () => IncomingServerEvents.notFound);
    final data = message["data"];
    switch(incomingEvent) {
      case IncomingServerEvents.availableLobbiesResponse: // response to the "getAvailableLobbies" request
        final availableLobbies = (data["lobbies"] as List<dynamic>).map((l) => Lobby.fromJson(l as Map<String, dynamic>)).toList();
        BlocService().fetchLobbiesBloc.add(FetchLobbiesSuccessEvent(lobbies: availableLobbies));
        break;
      case IncomingServerEvents.lobbyCreatedResponse:
        lobby = Lobby.fromJson(data);
        player = lobby!.players[0];
        BlocService().createLobbyBloc.add(CreateLobbySuccessEvent(lobby: lobby!));
        break;
      case IncomingServerEvents.joinLobbyResponse:
        lobby = Lobby.fromJson(data);
        player = lobby!.players.last;
        BlocService().joinLobbyBloc.add(JoinLobbySuccessEvent(lobby: lobby!));
        break;
      case IncomingServerEvents.lobbyUpdated:
        lobby = Lobby.fromJson(data);
        break;
      case IncomingServerEvents.lobbyClosing:
        lobby = Lobby.fromJson(data);
        break;
      case IncomingServerEvents.playerJoining:
        final player = LobbyPlayer.fromJson(data);
        lobby?.players.add(player);
        break;
      case IncomingServerEvents.playerUpdated:
        final playerId = data["id"];
        lobby?.players[playerId] = LobbyPlayer.fromJson(data);
        break;
      case IncomingServerEvents.playerLeaving:
        final player = LobbyPlayer.fromJson(data);
        lobby?.playerLeaving(player.id);
        break;
      case IncomingServerEvents.gameStarting:
        lobby = Lobby.fromJson(data);
        break;
      case IncomingServerEvents.gameEnding:
        lobby = Lobby.fromJson(data);
        break;
      case IncomingServerEvents.error:
        print("[ERROR] ${data["message"]}");
        break;
      case IncomingServerEvents.notFound:
        print("Event not found: ${message['action']}");
        return;
    }
  }

  void getAvailableLobbies() {
    _server.getAvailableLobbies();
  }

  void createLobby(String lobbyName, String playerName) async {
    _server.createLobby(lobbyName, playerName);
  }

  /// Tries to join a lobby, a lobby owner can't join another lobby. <br>
  /// lobbyId: The id of the lobby to join
  void joinLobby(String lobbyId, String playerName) async {
    if(isLobbyOwner) {
      return null;
    }
    _server.joinLobby(lobbyId, playerName);
  }

  void updatePlayer(LobbyPlayer player) async {
    if(lobby == null) {
      return;
    }
    _server.updatePlayerInLobby(lobby!.id, player);
  }

  void leaveLobby() async {
    if(lobby != null) {
      _server.leaveLobby(lobby!.id, player!.id.toString());
      lobby = null;
      player = null;
    }
  }

  void startGame() {
    //_game = game;
    if(lobby == null) {
      return;
    }
    _server.startGame(lobby!.id);
  }
}