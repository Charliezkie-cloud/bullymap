import 'package:flutter/material.dart';

class MapFab extends StatelessWidget {
  // Constants
  final VoidCallback? onPressed;
  final Widget child;
  final String tooltip;
  final double size;
  
  const MapFab({
    super.key,
    required this.onPressed,
    required this.child,
    required this.tooltip,
    this.size = 44,
  });

  // Widget methods
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.surface,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black54,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}