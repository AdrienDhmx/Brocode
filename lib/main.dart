import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'brocode.dart';
import 'overlays/main_menu.dart';

enum Routes {
  mainMenu(name: "MainMenu"),
  gameOver(name: "GameOver");

  const Routes({required this.name});

  final String name;
}

void main() {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // generate a theme from a color
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.blueAccent);

    return MaterialApp(
      debugShowCheckedModeBanner: false, // remove the debug banner when in debug mode
      theme: ThemeData.from(
          colorScheme: colorScheme,
          textTheme: getTextStyle(colorScheme),
          useMaterial3: true
      ),
      home: GameWidget<Brocode>.controlled(
        gameFactory: Brocode.new,
        overlayBuilderMap: {
          Routes.mainMenu.name: (context, game) => MainMenu(game: game,)
        },
        initialActiveOverlays: [Routes.mainMenu.name],
      ),
    );
  }

}