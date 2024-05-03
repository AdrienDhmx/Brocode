
import 'dart:convert';
import 'package:brocode/core/lobbies/lobby_player.dart';
import 'package:http/http.dart' as http;

import '../lobbies/lobby.dart';

extension ServerStringExtension on String {
  Uri toUri() {
    return Uri.parse(this);
  }
}

class ServerUtil {
  static const serverAddress = "http://173.249.8.29:8083";
  static const lobbyBaseRoute = "/lobby";

  static const lobbyRoute = serverAddress + lobbyBaseRoute;

  static String buildRoute(String mainRoute, {String parameter = "", String secondaryRoute = ""}) {
    String combinedRoute = mainRoute;
    if(parameter.isNotEmpty) {
      combinedRoute += "/$parameter";
    }
    if (secondaryRoute.isNotEmpty) {
      combinedRoute += "/$secondaryRoute";
    }
    return combinedRoute;
  }

  static Future<List<Lobby>> getAvailableLobbies() async {
    final httpResult = await http.get(buildRoute(lobbyRoute).toUri());

    if(httpResult.statusCode == 200) {
      final json = jsonDecode(httpResult.body);
      final lobbiesJson = json["lobbies"];
      if(lobbiesJson is Iterable) {
        List<Lobby> lobbies = [];
        for (var lobbyJson in lobbiesJson) {
          lobbies.add(Lobby.fromJson(lobbyJson, summary: true));
        }
        return lobbies;
      }
    } else {
      print("[BROCODE] getAvailableLobbies failed: ${httpResult.statusCode}");
      print(buildRoute(lobbyRoute));
    }

    return [];
  }

  static Future<Lobby?> createLobby(String lobbyName, String playerName) async {
    final body = {
      "name": lobbyName,
      "ownerName": playerName,
    };
    final response = await http.post(buildRoute(lobbyRoute).toUri(), body: jsonEncode(body));

    if(response.statusCode == 200) {
      return Lobby.fromJson(jsonDecode(response.body), playerSummary: true);
    } else {
      print("[BROCODE] createLobby failed: ${response.statusCode}");
    }
    return null;
  }

  static Future<(Lobby?, LobbyPlayer?)> joinLobby(String lobbyId, String playerName) async {
    final body = {
      "name": playerName,
    };
    final response = await http.post(buildRoute(lobbyRoute, parameter: lobbyId).toUri(), body: jsonEncode(body));

    if(response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final lobby = Lobby.fromJson(body["lobby"], playerSummary: true);
      final player = LobbyPlayer.fromJson(body["player"], summary: true);
      return (lobby, player);
    } else {
      print("[BROCODE] joinLobby failed: ${response.statusCode}");
    }
    return (null, null);
  }

  static Future<Lobby?> getLobby(String lobbyId) async {
    final response = await http.get(buildRoute(lobbyRoute, parameter: lobbyId).toUri());

    if(response.statusCode == 200) {
      return Lobby.fromJson(jsonDecode(response.body));
    } else {
      print("[BROCODE] getLobby failed: ${response.statusCode}");
    }

    return null;
  }

  static void deleteLobby(String lobbyId) {
    http.delete(buildRoute(lobbyRoute, parameter: lobbyId).toUri());
  }

  static Future<bool> leaveLobby(String lobbyId, String playerId) async {
    // serverAddress/lobby/:lobbyId/player/playerId
    String route = buildRoute(lobbyRoute, parameter: lobbyId, secondaryRoute: buildRoute("player", parameter: playerId));
    final response = await http.delete(route.toUri());
    return response.statusCode == 200;
  }

  static void startGame(String lobbyId) {
    http.put(buildRoute(lobbyRoute, parameter: lobbyId, secondaryRoute: "start-game").toUri());
  }
}

