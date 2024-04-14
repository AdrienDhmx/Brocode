
import 'dart:async';

import 'package:brocode/core/lobbies/lobby_connection.dart';

import '../utils/typedefs.dart';
import 'lobby_event_payload.dart';

/// Expose the common methods of a lobby and lobby peers
abstract class LobbyInterface {
  LobbyInterface({required this.name, required this.onEvent});

  /// name of the peer
  final String name;
  /// callback to handle incoming events
  final VoidCallback<LobbyEventPayload> onEvent;

  late LobbyConnectionInfo? connectionInfo;

  /// emit the data to the sockets
  void emit(dynamic data);

  /// Dispose of all the resources of the lobby
  Future dispose();
}