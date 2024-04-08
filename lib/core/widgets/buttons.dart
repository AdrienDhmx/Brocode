import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/platform_utils.dart';

class NavigateBackButton extends StatelessWidget {
  const NavigateBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded)
    );
  }
}


class SurfaceVariantFlatButton extends StatelessWidget {
  final ThemeData theme;
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const SurfaceVariantFlatButton({super.key,
    required this.text,
    required this.onPressed,
    required this.theme,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: theme.colorScheme.surfaceVariant,
      foregroundColor: theme.colorScheme.onSurfaceVariant,
      width: width,
      height: height,
    );
  }
}

class TertiaryFlatButton extends StatelessWidget {
  final ThemeData theme;
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const TertiaryFlatButton({super.key,
    required this.text,
    required this.onPressed,
    required this.theme,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: theme.colorScheme.tertiaryContainer,
      foregroundColor: theme.colorScheme.onTertiaryContainer,
      width: width,
      height: height,
    );
  }
}

class PrimaryFlatButton extends StatelessWidget {
  final ThemeData theme;
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const PrimaryFlatButton({super.key,
    required this.text,
    required this.onPressed,
    required this.theme,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: theme.colorScheme.primaryContainer,
      foregroundColor: theme.colorScheme.onPrimaryContainer,
      width: width,
      height: height,
    );
  }
}

class FlatButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double width;
  final double height;

  const FlatButton({super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
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
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
