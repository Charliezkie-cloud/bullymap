import 'package:bullymap/features/home/presentation/widgets/directions_action_button.dart';
import 'package:bullymap/features/home/presentation/widgets/recenter_action_button.dart';
import 'package:flutter/material.dart';

class MapActionButtons extends StatelessWidget {
  final VoidCallback onRecenter;
  final VoidCallback onDirections;
  final bool isLoading;

  const MapActionButtons({
    super.key,
    required this.onRecenter,
    required this.onDirections,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
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