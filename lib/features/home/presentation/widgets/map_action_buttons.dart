import 'package:bullymap/features/home/presentation/widgets/compas_action_button.dart';
import 'package:bullymap/features/home/presentation/widgets/directions_action_button.dart';
import 'package:bullymap/features/home/presentation/widgets/recenter_action_button.dart';
import 'package:flutter/material.dart';

class MapActionButtons extends StatelessWidget {
  final VoidCallback onRecenter;
  final VoidCallback onDirections;
  final bool isLoading;

  // Compas
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        if (showCompass)
          CompasActionButton(
            onPressed: onCompassPressed,
            bearing: bearing,
          ),

        RecenterActionButton(
          onPressed: onRecenter,
          isLoading: isLoading,
        ),

        DirectionsActionButton(
          onPressed: onDirections,
        ),
      ],
    );
  }
}