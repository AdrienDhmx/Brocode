import 'dart:io';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

bool isOnPhone() {
  return Platform.isAndroid || Platform.isIOS;
}

JoystickComponent createVirtualJoystick(Color color, {EdgeInsets? margin}) {
  Paint knobPaint = Paint();
  knobPaint.color = color.withAlpha(220);

  Paint backgroundPaint = Paint();
  backgroundPaint.color =color.withAlpha(100);

  return JoystickComponent(
    knob: CircleComponent(radius: 20, paint: knobPaint),
    background: CircleComponent(radius: 50, paint: backgroundPaint),
    margin: margin,
  );
}