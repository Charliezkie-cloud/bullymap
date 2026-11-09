import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationFloatingButtons extends StatelessWidget {
  final String _pushRoute;
  final bool _hasPrevious;
  final bool _hasNext;


  const NavigationFloatingButtons({
    super.key,
    required this._pushRoute,
    this._hasPrevious = true,
    this._hasNext = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          if (_hasPrevious)
            FloatingActionButton(
              heroTag: 'fab-left',
              onPressed: () => context.pop(),
              child: const Icon(Icons.arrow_back),
            ),
          if (_hasNext)
            FloatingActionButton(
              heroTag: 'fab-right',
              onPressed: () => context.push(_pushRoute),
              child: const Icon(Icons.arrow_forward),
            ),
        ]
      )
    );
  } 
}