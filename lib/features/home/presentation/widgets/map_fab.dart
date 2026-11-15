import 'package:flutter/material.dart';

class MapFab extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String tooltip;
  final double diameter;

  const MapFab({
    super.key,
    required this.onPressed,
    required this.child,
    required this.tooltip,
    this.diameter = 44,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colorScheme.surface,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black54,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: diameter,
            height: diameter,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
