
import '../../lobbies/lobby.dart';

abstract class FetchLobbiesEvent {
  const FetchLobbiesEvent();
}

class FetchLobbiesInitEvent extends FetchLobbiesEvent {}

class FetchLobbiesFetchEvent extends FetchLobbiesEvent {
  // could add some filter here (for searching lobbies by name for example)
}

class FetchLobbiesSuccessEvent extends FetchLobbiesEvent {
  final List<Lobby> lobbies;

  FetchLobbiesSuccessEvent({required this.lobbies});
}