import 'package:flutter/material.dart';

class DirectionsActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DirectionsActionButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null,
      onPressed: onPressed,
      child: const Icon(Icons.directions),
    );
  }
}