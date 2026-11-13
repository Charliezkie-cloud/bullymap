import 'dart:math' as math;

import 'package:bullymap/features/home/presentation/widgets/directions_action_button.dart';
import 'package:bullymap/features/home/presentation/widgets/map_fab.dart';
import 'package:flutter/material.dart';

class MapActionButtons extends StatelessWidget {
  // Constants
  final VoidCallback onRecenter;
  final VoidCallback onDirections;
  final bool isLoading;

  // Compass constants
  final double bearing;
  final VoidCallback onCompassPressed;
  final bool showCompass;

  const MapActionButtons({
    super.key,

    required this.onRecenter,
    required this.onDirections,

    required this.bearing,
    required this.onCompassPressed,
    required this.showCompass,

    this.isLoading = false,
  });

  // Widget methods
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        if (showCompass)
          MapFab(
            tooltip: 'Reset north',
            onPressed: onCompassPressed,
            child: Transform.rotate(
              angle: -bearing * math.pi / 180,
              child: const Icon(Icons.navigation, color: Colors.red),
            ),
          ),

        MapFab(
          tooltip: "Recenter",
          onPressed: !isLoading ? onRecenter : null,
          child: !isLoading ? const Icon(Icons.my_location) : SizedBox(
            height: 26,
            width: 26,
            child: const CircularProgressIndicator(strokeWidth: 3)
          )
        ),

        DirectionsActionButton(
          onPressed: onDirections,
        ),
      ]
    );
  }
}