

import '../../lobbies/lobby.dart';

abstract class JoinLobbyState {
  const JoinLobbyState();
}

class JoinLobbyInitState extends JoinLobbyState {}

class JoinLobbyLoadingState extends JoinLobbyState {}

class JoinLobbySuccessState extends JoinLobbyState {
  final Lobby lobby;

  JoinLobbySuccessState({required this.lobby});
}

class JoinLobbyErrorState extends JoinLobbyState {
  final String errorMessage;

  JoinLobbyErrorState({required this.errorMessage});
}