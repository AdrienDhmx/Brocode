

import 'dart:async';

import 'package:brocode/core/blocs/create_lobby/create_lobby_events.dart';
import 'package:brocode/core/blocs/create_lobby/create_lobby_states.dart';
import 'package:brocode/core/services/lobby_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateLobbyBloc extends Bloc<CreateLobbyEvent, CreateLobbyState> {
  static const creationLobbyTimeout = 4000; // 4 seconds
  Timer? _lobbyCreationTimer;

  CreateLobbyBloc() : super(CreateLobbyInitState()) {
   on((event, emit) {
     if(event is CreateLobbyInitEvent) { // init state
       emit(CreateLobbyInitState());
       return;
     }

     if(event is CreateLobbyCreateEvent) { // loading state
       emit(CreateLobbyLoadingState());
       LobbyService().createLobby(event.name, event.ownerName);
       // start a timer to emit an error state after 4 seconds if the lobby is not created
       _lobbyCreationTimer = Timer(const Duration(milliseconds: creationLobbyTimeout), () {
         // can't emit 4 seconds in the future because the emit method is passed as a parameter in the "on" callback function
         // and we return (leave the "on" function) before the 4 seconds passed
         add(CreateLobbyErrorEvent(errorMessage: "Le lobby n'a pas pu être créer, vérifier votre connection internet et réessayer."));
       });
       return;
     }

     if(event is CreateLobbySuccessEvent) { // success state
       _lobbyCreationTimer?.cancel(); // stop the timeout timer if any
       emit(CreateLobbyCreatedState(lobby: event.lobby));
       return;
     }

     if(event is CreateLobbyErrorEvent) { // error state
       emit(CreateLobbyErrorState(errorMessage: event.errorMessage));
       return;
     }
   });
  }
}