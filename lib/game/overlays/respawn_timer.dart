

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../brocode.dart';
import '../player.dart';

class RespawnTimer extends StatefulWidget {
  const RespawnTimer({super.key, required this.game});

  final Brocode game;

  @override
  State<StatefulWidget> createState() => _RespawnTimer();
}

class _RespawnTimer extends State<RespawnTimer> {
  late double second;
  late Timer _timer;

  static const timerDuration = 100;

  void onSecondPassed(Timer timer) {
    setState(() {
      second -= timerDuration / 1000;
    });

    if(second == 0) {
      timer.cancel();
    }
  }

  @override
  void initState() {
    super.initState();

    second = Player.respawnDuration;
    _timer = Timer.periodic(const Duration(milliseconds: timerDuration), onSecondPassed);
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(80),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
          ),
          child: Text(
            second.toStringAsFixed(1),
          ),
        ),
      ),
    );
  }

}