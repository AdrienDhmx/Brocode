import 'package:brocode/app/screens/create_lobby.dart';
import 'package:brocode/app/screens/game.dart';
import 'package:brocode/app/screens/lobby.dart';
import 'package:go_router/go_router.dart';

import 'screens/main_menu.dart';

enum Routes {
  mainMenu(name: "MainMenu", route: "/"),
  createLobby(name: "CreateLobby", route: "/create_lobby"),
  lobby(name: "lobby", route: '/lobby/:lobbyId'),
  game(name: "Game", route: '/game'),
  gameOver(name: "GameOver", route: '/game/over');

  const Routes({required this.name, required this.route});

  final String name;
  final String route;

  String withParameters(Map<String, String> parameters) {
    String replacedRoute = route;
    parameters.forEach((key, value) {
      replacedRoute = replacedRoute.replaceAll(':$key', value);
    });
    return replacedRoute;
  }
}

GoRouter getGoRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: Routes.mainMenu.route,
        builder: (context, state) => const MainMenu(),
      ),
      GoRoute(
        path: Routes.lobby.route,
        builder: (context, state) =>state.pathParameters['lobbyId'] == null
            ? const MainMenu()
            : LobbyWaitingPage(lobbyId: state.pathParameters['lobbyId']!,)
      ),
      GoRoute(
        path: Routes.createLobby.route,
        builder: (context, state) => const CreateLobby(),
      ),
      GoRoute(
        path: Routes.game.route,
        builder: (context, state) => const GameScreen(),
      ),
      GoRoute(
        path: Routes.gameOver.route,
        builder: (context, state) => const MainMenu(),
      ),
    ],
  );
}