import 'package:bullymap/features/home/controllers/navigation_controller.dart';
import 'package:bullymap/features/home/data/models/navigation_route.dart';
import 'package:bullymap/features/home/data/models/navigation_step.dart';
import 'package:flutter/material.dart';

class NavigationHud extends StatefulWidget {
  const NavigationHud({ super.key });

  @override
  State<NavigationHud> createState() => _NavigationHudState();
}

class _NavigationHudState extends State<NavigationHud>
    with SingleTickerProviderStateMixin {
  // States
  late final AnimationController _controller;
  late final CurvedAnimation _slideCurve;
  late final Animation<Offset> _topSlide;
  late final Animation<Offset> _bottomSlide;
  bool _isVisible = NavigationController.isNavigating.value;
  NavigationStep? _lastStep;
  NavigationRoute? _lastRoute;
  double _lastDistance = 0.0;

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

  // stopNavigation() clears the route data before the exit animation ends,
  // so keep a snapshot to slide out with the content still visible.
  void _handleIsNavigatingChanged() {
    if (NavigationController.isNavigating.value) {
      if (!_isVisible) setState(() => _isVisible = true);
      _controller.forward();
      return;
    }

    _lastStep = NavigationController.currentStep.value;
    _lastRoute = NavigationController.activeRoute.value;
    _lastDistance = NavigationController.remainingDistance.value;

    _controller.reverse().whenComplete(() {
      if (!mounted) return;
      if (NavigationController.isNavigating.value) return;
      setState(() => _isVisible = false);
    });
  }

  // Widget methods
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _topSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(_slideCurve);
    _bottomSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(_slideCurve);

    NavigationController.isNavigating.addListener(_handleIsNavigatingChanged);
    if (_isVisible) _controller.value = 1;
  }

  @override
  void dispose() {
    NavigationController.isNavigating.removeListener(
      _handleIsNavigatingChanged,
    );
    _slideCurve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Stack(
      children: [
        // Top Turn-by-Turn Banner (Google Maps style)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _topSlide,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: ValueListenableBuilder<NavigationStep?>(
                  valueListenable: NavigationController.currentStep,
                  builder: (context, currentStep, _) {
                    final step = currentStep ?? _lastStep;
                    if (step == null) return const SizedBox.shrink();

                    return Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF15803D),
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
        ),

        // Bottom Navigation Card (Google Maps style)
        Positioned(
          left: 12,
          right: 12,
          bottom: 0,
          child: SlideTransition(
            position: _bottomSlide,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
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
                      builder: (context, activeRoute, _) {
                        final route = activeRoute ?? _lastRoute;

                        return ValueListenableBuilder<double>(
                          valueListenable:
                              NavigationController.remainingDistance,
                          builder: (context, remainingDistance, _) {
                            final distance = remainingDistance > 0
                                ? remainingDistance
                                : _lastDistance;
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
                                          color: Color(0xFF15803D),
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
          ),
        ),
      ],
    );
  }
}
