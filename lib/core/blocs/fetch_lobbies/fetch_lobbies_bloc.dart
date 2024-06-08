

import 'package:brocode/core/blocs/fetch_lobbies/fetch_lobbies_events.dart';
import 'package:brocode/core/blocs/fetch_lobbies/fetch_lobbies_states.dart';
import 'package:brocode/core/services/lobby_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FetchLobbiesBloc extends Bloc<FetchLobbiesEvent, FetchLobbiesState> {
  FetchLobbiesBloc() : super(const FetchLobbiesInitState()) {
    on((event, emit) {
      if(event is FetchLobbiesInitEvent) { // init state
        emit(FetchLobbiesInitState(lobbies: state.lobbies));
        return;
      }

      if(event is FetchLobbiesFetchEvent) { // loading state
        emit(FetchLobbiesLoadingState(lobbies: state.lobbies));
        LobbyService().getAvailableLobbies();
        return;
      }

      if(event is FetchLobbiesSuccessEvent) { // success state
        emit(FetchLobbiesSuccessState(lobbies: event.lobbies));
        return;
      }
    });
  }
}