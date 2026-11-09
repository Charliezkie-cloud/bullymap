import 'package:flutter/material.dart';

class RecenterActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const RecenterActionButton({
    super.key,
    required this.onPressed,
    this.isLoading = false
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading ? const CircularProgressIndicator() : const Icon(Icons.my_location),
    );
  }
}