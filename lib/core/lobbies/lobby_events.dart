import 'dart:convert';

import 'package:brocode/core/lobbies/lobby_event_payload.dart';

import 'lobby_peer_interface.dart';

enum LobbyEvents {
  playerJoining, // first event a player emit when connecting to a lobby
  playerLeaving, // connection closed

  playerState,

  lobbyState, // update the name of the lobby, the list of players...

  connectionFailed, // peer tried to connect to other peer but failed
}

extension LobbyEventExtension on LobbyEvents {
  /// Create a new event message based on this event
  Map<String, dynamic> eventMessage(dynamic data, LobbyInterface lobbyPeer) {
    final lobbyEventPayload = LobbyEventPayload(eventId: index, eventName: name, senderConnectionInfo: lobbyPeer.connectionInfo!, senderName: lobbyPeer.name, data: data);
    return lobbyEventPayload.toLobbyEventMessage();
  }

  /// Emit this event
  void emit(dynamic data, LobbyInterface lobbyPeer) async {
    final jsonString = jsonEncode(eventMessage(data, lobbyPeer));
    lobbyPeer.emit(jsonString);
  }
}