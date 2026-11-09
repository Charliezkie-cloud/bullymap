import 'dart:math' as math;

import 'package:flutter/material.dart';

class CompasActionButton extends StatelessWidget {
  final double bearing;
  final VoidCallback onPressed;

  const CompasActionButton({
    super.key,
    required this.bearing,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 3,
      onPressed: onPressed,
      shape: const CircleBorder(),
      child: Transform.rotate(
        angle: -bearing * (math.pi / 180),
        child: const Icon(Icons.navigation)
      )
    );
  }
}