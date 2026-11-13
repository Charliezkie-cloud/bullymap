import 'package:bullymap/features/home/controllers/navigation_controller.dart';
import 'package:bullymap/features/home/models/navigation_route.dart';
import 'package:bullymap/features/home/models/navigation_step.dart';
import 'package:flutter/material.dart';

class NavigationHud extends StatelessWidget {
  const NavigationHud({ super.key });

  // Methods
  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  // Widget methods
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: NavigationController.isNavigating,
      builder: (context, isNavigating, _) {
        if (!isNavigating) return const SizedBox.shrink();

        return Stack(
          children: [
            // Top Turn-by-Turn Banner (Google Maps style)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ValueListenableBuilder<NavigationStep?>(
                    valueListenable: NavigationController.currentStep,
                    builder: (context, step, _) {
                      if (step == null) return const SizedBox.shrink();

                      return Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF0F5132),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                step.maneuverIcon,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      step.formattedDistance,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      step.instruction,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom Navigation Card (Google Maps style)
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: ValueListenableBuilder<NavigationRoute?>(
                      valueListenable: NavigationController.activeRoute,
                      builder: (context, route, _) {
                        return ValueListenableBuilder<double>(
                          valueListenable:
                              NavigationController.remainingDistance,
                          builder: (context, distance, _) {
                            final duration =
                                (route != null && route.distance > 0)
                                ? (distance / route.distance) * route.duration
                                : 0.0;

                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatDuration(duration),
                                        style: const TextStyle(
                                          color: Color(0xFF0F5132),
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_formatDistance(distance)} • ETA ${route?.etaString ?? '--'}',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton.filledTonal(
                                  onPressed: NavigationController.recenterCamera,
                                  icon: const Icon(Icons.navigation_rounded),
                                  tooltip: 'Recenter',
                                ),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                  onPressed: NavigationController.stopNavigation,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.close),
                                  tooltip: 'Exit navigation',
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
