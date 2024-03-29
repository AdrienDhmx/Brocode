

import 'package:brocode/utils/platform_utils.dart';
import 'package:flutter/material.dart';

TextButton tertiaryFlatButton(ThemeData theme, String text, onPressed, {double width = double.infinity, double height = double.infinity}) {
  return flatButton(text, onPressed,
    backgroundColor: theme.colorScheme.tertiaryContainer,
    foregroundColor: theme.colorScheme.onTertiaryContainer,
    width: width,
    height: height,
  );
}

TextButton primaryFlatButton(ThemeData theme, String text, onPressed, {double width = double.infinity, double height = double.infinity}) {
  return flatButton(text, onPressed,
    backgroundColor: theme.colorScheme.primaryContainer,
    foregroundColor: theme.colorScheme.onPrimaryContainer,
    width: width,
    height: height,
  );
}

TextButton flatButton(String text, onPressed, {required Color backgroundColor, required Color foregroundColor,  double width = double.infinity, double height = double.infinity}) {
  return TextButton( // Create lobby
    style: TextButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      fixedSize: Size(width, height),
    ),
    onPressed: onPressed,
    child: Padding(
      padding: isOnPhone()
          ? const EdgeInsets.symmetric(vertical: 4, horizontal: 10)
          : const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Text(text),
    ),
  );
}