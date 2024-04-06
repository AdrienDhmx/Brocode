import 'package:brocode/app/screens/game.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';

import '../game/brocode.dart';
import 'screens/main_menu.dart';

enum Routes {
  mainMenu(name: "MainMenu", route: "/"),
  game(name: "Game", route: '/game'),
  gameOver(name: "GameOver", route: '/game/over');

  const Routes({required this.name, required this.route});

  final String name;
  final String route;
}

GoRouter getGoRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: Routes.mainMenu.route,
        builder: (context, state) => const MainMenu(),
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