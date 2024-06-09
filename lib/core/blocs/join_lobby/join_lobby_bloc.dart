
import 'dart:async';

import 'package:brocode/core/blocs/join_lobby/join_lobby_states.dart';
import 'package:brocode/core/services/lobby_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'join_lobby_events.dart';

class JoinLobbyBloc extends Bloc<JoinLobbyEvent, JoinLobbyState> {
  static const joinLobbyTimeout = 4000; // 4 seconds
  Timer? _joinLobbyTimer;

  JoinLobbyBloc() : super(JoinLobbyInitState()) {
    on((event, emit) {
      if(event is JoinLobbyInitEvent) {
        emit(JoinLobbyInitState());
        return;
      }

      if(event is JoinLobbyJoinEvent) {
        emit(JoinLobbyLoadingState());
        LobbyService().joinLobby(event.lobbyId, event.playerName);
        _joinLobbyTimer = Timer(const Duration(milliseconds: joinLobbyTimeout), () {
          add(JoinLobbyErrorEvent(errorMessage: "Échec de la connexion au lobby : vérifier votre connection internet et réessayer"));
        });
        return;
      }

      if(event is JoinLobbySuccessEvent) {
        _joinLobbyTimer?.cancel();
        emit(JoinLobbySuccessState(lobby: event.lobby));
        return;
      }

      if(event is JoinLobbyErrorEvent) {
        emit(JoinLobbyErrorState(errorMessage: event.errorMessage));
        return;
      }
    });
  }

}