
import 'package:brocode/core/lobbies/lobby.dart';

abstract class CreateLobbyState {
  const CreateLobbyState();
}

class CreateLobbyInitState extends CreateLobbyState {}

class CreateLobbyLoadingState extends CreateLobbyState {}

class CreateLobbyCreatedState extends CreateLobbyState {
  final Lobby lobby;

  CreateLobbyCreatedState({required this.lobby});
}

class CreateLobbyErrorState extends CreateLobbyState {
  final String errorMessage;

  CreateLobbyErrorState({required this.errorMessage});
}