
import '../../lobbies/lobby.dart';

abstract class CreateLobbyEvent {
  const CreateLobbyEvent();
}

class CreateLobbyInitEvent extends CreateLobbyEvent {}

class CreateLobbyCreateEvent extends CreateLobbyEvent {
  final String name;
  final String ownerName;
  // add more data about lobby and owner (character color...)

  CreateLobbyCreateEvent({required this.name, required this.ownerName});
}

class CreateLobbySuccessEvent extends CreateLobbyEvent {
  final Lobby lobby;

  CreateLobbySuccessEvent({required this.lobby});
}

class CreateLobbyErrorEvent extends CreateLobbyEvent {
  final String errorMessage;

  CreateLobbyErrorEvent({required this.errorMessage});
}