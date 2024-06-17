import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../lobbies/lobby_player.dart';

enum IncomingServerEvents {
  availableLobbiesResponse,
  joinLobbyResponse,
  lobbyCreatedResponse,

  lobbyUpdated,
  lobbyClosing,

  playerJoining,
  playerUpdated,
  playerLeaving,

  gameStarting,
  gameEnding,

  error,
  notFound,
}

class ServerService {
  static const serverAddress = /*"173.249.8.29";*/ "127.0.0.1";
  static int serverPort = 8083;
  static const lobbyBaseRoute = "/lobby";
  static const playerBaseRoute = "player";

  static const lobbyRoute = serverAddress + lobbyBaseRoute;

  final void Function(Map<String, dynamic> data) handleMessage;
  late Socket? _socket;
  bool get isConnected => _socket != null;

  ServerService({required this.handleMessage});

  Future connectToServer() async {
    try {
      _socket = await Socket.connect(serverAddress, serverPort);
      _socket!.setOption(SocketOption.tcpNoDelay, true);
      _socket!.listen((Uint8List encodedMessage) {
          String decodedMessage = utf8.decode(encodedMessage);

          if(decodedMessage.contains("}{")) {
            final messages = decodedMessage.split("}{");
            decodedMessage = '{${messages[messages.length - 1]}';
          }
          try {
            handleMessage(jsonDecode(decodedMessage));
          } catch (e) {
            if(kDebugMode) {
              print(decodedMessage);
            }
          }
        },
        onDone: () {
          _socket!.destroy();
          _socket = null;
          print('WebSocket connection closed');
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
      );
    } catch (e) {
      print('Error connecting to server: $e');
    }
  }


  void disconnectFromServer() {
    _socket?.close();
  }

  void sendAction(Map<String, dynamic> data) {
    _socket?.write(jsonEncode(data));
  }

  void getAvailableLobbies() async {
    sendAction({'action': 'getAvailableLobbies'});
  }

  void createLobby(String lobbyName, String playerName) async {
    sendAction({'action': 'createLobby', 'name': lobbyName, 'ownerName': playerName});
  }

  void joinLobby(String lobbyId, String playerName) async {
    sendAction({'action': 'joinLobby', 'lobbyId': lobbyId, 'name': playerName});
  }

  void getLobby(String lobbyId) async {
    sendAction({'action': 'getLobby', 'lobbyId': lobbyId});
  }

  void updatePlayerInLobby(String lobbyId, LobbyPlayer player) async {
    sendAction({'action': 'updatePlayer', 'lobbyId': lobbyId, 'playerId': player.id, ...player.getJsonPlayerState()});
  }

  void deleteLobby(String lobbyId) {
    sendAction({'action': 'deleteLobby', 'lobbyId': lobbyId});
  }

  void leaveLobby(String lobbyId, String playerId) async {
    sendAction({'action': 'playerLeaveLobby', 'lobbyId': lobbyId, 'playerId': playerId});
  }

  void startGame(String lobbyId) {
    sendAction({'action': 'startGame', 'lobbyId': lobbyId});
  }
}