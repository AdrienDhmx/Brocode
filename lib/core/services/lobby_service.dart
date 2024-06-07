
import 'package:brocode/core/lobbies/lobby_player.dart';
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

  List<Lobby> availableLobbies = [];

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
        availableLobbies = (data["lobbies"] as List<dynamic>).map((l) => Lobby.fromJson(l as Map<String, dynamic>)).toList();
        break;
      case IncomingServerEvents.lobbyCreatedResponse:
        lobby = Lobby.fromJson(data);
        player = lobby?.players[0];
        break;
      case IncomingServerEvents.joinLobbyResponse:
        lobby = Lobby.fromJson(data);
        player = lobby?.players.last;
        break;
      case IncomingServerEvents.lobbyUpdated:
        lobby?.updateWithLobby(Lobby.fromJson(data));
        break;
      case IncomingServerEvents.lobbyClosing:
      // TODO: handle lobby closing
        break;
      case IncomingServerEvents.playerJoining:
        final player = LobbyPlayer.fromJson(data);
        lobby?.players.add(player);
        break;
      case IncomingServerEvents.playerUpdated:
        final playerId = data["id"];
        lobby?.players[playerId].updateFromJson(data);
        break;
      case IncomingServerEvents.playerLeaving:
        final player = LobbyPlayer.fromJson(data);
        lobby?.playerLeaving(player.id);
        break;
      case IncomingServerEvents.gameStarting:
        lobby?.startGame();
        break;
      case IncomingServerEvents.gameEnding:
        break;
      case IncomingServerEvents.error:
        print("[ERROR] ${data["message"]}");
        break;
      case IncomingServerEvents.notFound:
        print("Event not found: ${message['action']}");
        return;
    }
  }

  List<Lobby> getAvailableLobbies() {
    _server.getAvailableLobbies();
    return availableLobbies;
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
    _server.leaveLobby(lobby!.id, player!.id.toString());
  }

  void startGame() {
    //_game = game;
    if(lobby == null) {
      return;
    }
    lobby!.startGame();
    _server.startGame(lobby!.id);
  }
}