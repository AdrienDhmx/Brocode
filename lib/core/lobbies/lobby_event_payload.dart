import 'package:brocode/core/lobbies/lobby_connection.dart';
import 'package:brocode/core/lobbies/lobby_events.dart';
import 'package:brocode/core/lobbies/lobby_peer_interface.dart';

class LobbyEventPayload {
  LobbyEventPayload({
    required this.eventId,
    required this.eventName,
    required this.senderConnectionInfo,
    required this.senderName,
    required this.data,
  });

  final int eventId;
  final String eventName;

  final LobbyConnectionInfo senderConnectionInfo;
  final String senderName;

  final dynamic data;

  static LobbyEventPayload fromLobbyEvent(LobbyEvents event, dynamic data, LobbyInterface lobbyPeer) {
    return fromLobbyEventMessage(event.eventMessage(data, lobbyPeer));
  }
  static LobbyEventPayload fromLobbyEventMessage(Map<String, dynamic> lobbyEvent) {
    final sender = lobbyEvent["sender"];
    final event = lobbyEvent["event"];
    final eventData = lobbyEvent["data"];

    if(event == null) {
      throw ArgumentError("The event is not specified: $lobbyEvent");
    }

    final eventId = int.tryParse(event!["id"].toString());
    if(eventId == null) {
      throw ArgumentError("The event id is not set or not of type int: ${event?["id"]}");
    }

    if (sender != null && sender is Map<String, dynamic> &&
        sender.containsKey("address") &&
        sender.containsKey("port") && sender.containsKey("name")) {
      return LobbyEventPayload(
        eventId: eventId,
        eventName: event["name"].toString(),
        senderConnectionInfo: LobbyConnectionInfo.fromJson(sender)!,
        senderName: sender["name"].toString(),
        data: eventData,
      );
    } else {
      throw ArgumentError("Invalid sender data in lobby event: $lobbyEvent.");
    }
  }

  Map<String, dynamic> toLobbyEventMessage() {
    return {
      "event": {
        "id": eventId,
        "name": eventName,
      },
      "sender": {
        ...senderConnectionInfo.toJson(),
        "name": senderName,
      },
      "data": data,
    };
  }
}
