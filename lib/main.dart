import 'package:brocode/app/router.dart';
import 'package:brocode/core/blocs/fetch_lobbies/fetch_lobbies_bloc.dart';
import 'package:brocode/core/services/lobby_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/bloc_service.dart';

void main() {
  LobbyService();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  TextTheme getTextStyle(ColorScheme colorScheme) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.w700,
        color: colorScheme.primary,
      ),
      headlineSmall: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // generate a theme from a color (the blue of the blue gunner)
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 79, 116, 194));

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BlocService().fetchLobbiesBloc),
        BlocProvider(create: (_) => BlocService().createLobbyBloc),
        BlocProvider(create: (_) => BlocService().joinLobbyBloc),
        BlocProvider(create: (_) => BlocService().currentLobbyCubit),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false, // remove the debug banner when in debug mode
        theme: ThemeData.from(
            colorScheme: colorScheme,
            textTheme: getTextStyle(colorScheme),
            useMaterial3: true
        ),
        routerConfig: getGoRouter(),
      ),
    );
  }
}