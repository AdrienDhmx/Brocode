

import 'package:brocode/core/lobbies/lobby.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentLobbyCubit extends Cubit<Lobby?> {
  CurrentLobbyCubit() : super(null);

  void updateLobby(Lobby? lobby) {
    emit(lobby);
  }
}