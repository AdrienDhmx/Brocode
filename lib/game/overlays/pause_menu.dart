

import 'package:brocode/core/widgets/buttons.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/utils/platform_utils.dart';
import '../brocode.dart';

class PauseMenu extends StatefulWidget {
  const PauseMenu({super.key, required this.game});
  final Brocode game;

  @override
  State<StatefulWidget> createState() => _PauseMenu();
}

class _PauseMenu extends State<PauseMenu> {
  void leaveGame() async {
    if(isOnPhone()) {
      await Flame.device.setPortrait();
    }
    if(mounted && context.mounted) {
      context.go(Routes.mainMenu.route);
    }
  }

  void closePauseMenu() {
    widget.game.closePauseMenu();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                color: const Color.fromARGB(120, 10, 10, 10),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.05, horizontal: constraints.maxWidth * 0.05),
                    child: Material(
                      elevation: 2,
                      surfaceTintColor: theme.colorScheme.surfaceTint,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 800,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Text("Pause", style: theme.textTheme.headlineSmall, textAlign: TextAlign.center,),
                              ),
                              PrimaryFlatButton(text: "Retour", onPressed: closePauseMenu, theme: theme, width: 120, height: 50,),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: TertiaryFlatButton(text: "Quitter", onPressed: leaveGame, theme: theme, width: 120, height: 50,),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
          }
        );
  }

}