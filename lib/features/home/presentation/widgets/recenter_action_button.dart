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
      child: !isLoading ? const Icon(Icons.my_location) : SizedBox(
        height: 26,
        width: 26,
        child: const CircularProgressIndicator(strokeWidth: 3)
      )
    );
  }
}