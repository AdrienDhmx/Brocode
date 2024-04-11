
import 'package:brocode/core/lobbies/lobby_event_payload.dart';

import 'lobby_peer_interface.dart';

enum LobbyEvents {
  playerLeaving, // connection closed

  playerState,

  lobbyState, // update the name of the lobby, the list of players...

  connectionOpened, // could be renamed player joining
  connectionFailed, // peer tried to connect to other peer but failed
}

extension LobbyEventExtension on LobbyEvents {
  /// Create a new event message based on this event
  Map<String, dynamic> eventMessage(dynamic data, LobbyPeerInterface lobbyPeer) {
    final lobbyEventPayload = LobbyEventPayload(eventId: index, eventName: name, senderId: lobbyPeer.peer.id!, senderName: lobbyPeer.name, data: data);
    return lobbyEventPayload.toLobbyEventMessage();
  }

  /// Emit this event
  void emit(dynamic data, LobbyPeerInterface lobbyPeer) {
    lobbyPeer.emit(eventMessage(data, lobbyPeer));
  }
}