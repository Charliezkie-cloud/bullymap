import 'dart:math' as math;

import 'package:bullymap/features/home/presentation/widgets/directions_action_button.dart';
import 'package:bullymap/features/home/presentation/widgets/map_fab.dart';
import 'package:flutter/material.dart';

class MapActionButtons extends StatelessWidget {
  final VoidCallback onCompassPressed;
  final VoidCallback onRecenterPressed;
  final VoidCallback onDirectionsPressed;

  final double mapBearing;
  final bool showCompass;
  final bool isLoadingLocation;

  const MapActionButtons({
    super.key,

    required this.onCompassPressed,
    required this.onRecenterPressed,
    required this.onDirectionsPressed,

    required this.mapBearing,
    required this.showCompass,
    this.isLoadingLocation = false,
  });

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
              angle: -mapBearing * math.pi / 180,
              child: const Icon(Icons.navigation, color: Colors.red),
            ),
          ),

        MapFab(
          tooltip: 'Recenter',
          onPressed: !isLoadingLocation ? onRecenterPressed : null,
          child: !isLoadingLocation
              ? const Icon(Icons.my_location)
              : const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
        ),
      ],
    );
  }
}
