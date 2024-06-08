

import '../../lobbies/lobby.dart';

abstract class FetchLobbiesState {
  final List<Lobby> lobbies;

  const FetchLobbiesState({this.lobbies = const []});
}

class FetchLobbiesInitState extends FetchLobbiesState {
  const FetchLobbiesInitState({super.lobbies = const []});
}

class FetchLobbiesLoadingState extends FetchLobbiesState {
  const FetchLobbiesLoadingState({super.lobbies = const []});
}

class FetchLobbiesSuccessState extends FetchLobbiesState {
  const FetchLobbiesSuccessState({super.lobbies = const []});
}

