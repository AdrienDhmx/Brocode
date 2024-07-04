

import 'package:flutter/material.dart';

import '../brocode.dart';

class PauseMenuButton extends StatelessWidget {
  const PauseMenuButton({super.key, required this.game});
  final Brocode game;

  void openPauseMenu() {
    game.openPauseMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        onPressed: openPauseMenu,
        color: Colors.white,
        icon: const Icon(Icons.pause_rounded),
      ),
    );
  }

}