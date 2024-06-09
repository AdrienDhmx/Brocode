

import 'dart:async';

import 'package:brocode/core/blocs/fetch_lobbies/fetch_lobbies_events.dart';
import 'package:brocode/core/blocs/fetch_lobbies/fetch_lobbies_states.dart';
import 'package:brocode/core/services/lobby_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FetchLobbiesBloc extends Bloc<FetchLobbiesEvent, FetchLobbiesState> {
  static const refreshRate = 500;
  Timer? _refreshTimer;

  FetchLobbiesBloc() : super(const FetchLobbiesInitState()) {
    on((event, emit) {
      if(event is FetchLobbiesInitEvent) { // init state
        _refreshTimer?.cancel();
        emit(FetchLobbiesInitState(lobbies: state.lobbies));
        return;
      }

      if(event is FetchLobbiesFetchEvent) { // loading state
        _refreshTimer?.cancel();
        emit(FetchLobbiesLoadingState(lobbies: state.lobbies));
        LobbyService().getAvailableLobbies();
        return;
      }

      if(event is FetchLobbiesSuccessEvent) { // success state
        emit(FetchLobbiesSuccessState(lobbies: event.lobbies));
        Timer(const Duration(milliseconds: refreshRate), () {
          LobbyService().getAvailableLobbies();
        });
        return;
      }
    });
  }
}