import 'package:brocode/app/router.dart';
import 'package:flutter/material.dart';

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
      headlineSmall: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // generate a theme from a color
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.blueAccent);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false, // remove the debug banner when in debug mode
      theme: ThemeData.from(
          colorScheme: colorScheme,
          textTheme: getTextStyle(colorScheme),
          useMaterial3: true
      ),
      routerConfig: getGoRouter(),
    );
  }
}