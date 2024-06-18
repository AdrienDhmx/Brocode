
import 'package:brocode/core/lobbies/lobby.dart';

abstract class JoinLobbyEvent {
  const JoinLobbyEvent();
}

class JoinLobbyInitEvent extends JoinLobbyEvent {}

class JoinLobbyJoinEvent extends JoinLobbyEvent {
  final String lobbyId;
  final String playerName;

  JoinLobbyJoinEvent({required this.lobbyId, required this.playerName});
}

class JoinLobbySuccessEvent extends JoinLobbyEvent {
  final Lobby lobby;

  JoinLobbySuccessEvent({required this.lobby});
}

class JoinLobbyErrorEvent extends JoinLobbyEvent {
  final String errorMessage;

  JoinLobbyErrorEvent({required this.errorMessage});
}