

import 'package:brocode/core/blocs/fetch_lobbies/fetch_lobbies_bloc.dart';
import 'package:brocode/core/blocs/join_lobby/join_lobby_bloc.dart';

import '../blocs/create_lobby/create_lobby_bloc.dart';

class BlocService {
  static final BlocService _instance = BlocService._internal();
  static BlocService get instance => _instance;
  factory BlocService() {
    return _instance;
  }
  BlocService._internal();

  final FetchLobbiesBloc fetchLobbiesBloc = FetchLobbiesBloc();
  final CreateLobbyBloc createLobbyBloc = CreateLobbyBloc();
  final JoinLobbyBloc joinLobbyBloc = JoinLobbyBloc();
}