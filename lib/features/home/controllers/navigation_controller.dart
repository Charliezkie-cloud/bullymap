import 'dart:async';
import 'dart:math' as math;

import 'package:bullymap/core/services/location_service.dart';
import 'package:bullymap/features/home/controllers/map_controller.dart';
import 'package:bullymap/features/home/data/services/directions_service.dart';
import 'package:bullymap/features/home/data/services/navigation_audio_service.dart';
import 'package:bullymap/features/home/data/services/navigation_voice_service.dart';
import 'package:bullymap/features/home/data/models/navigation_route.dart';
import 'package:bullymap/features/home/data/models/navigation_step.dart';
import 'package:bullymap/features/home/data/models/pinned_location.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class NavigationController {
  // Notifiers
  static final ValueNotifier<bool> isNavigating = ValueNotifier(false);
  static final ValueNotifier<bool> isLoading = ValueNotifier(false);
  static final ValueNotifier<NavigationRoute?> activeRoute = ValueNotifier(null);
  static final ValueNotifier<NavigationStep?> currentStep = ValueNotifier(null);
  static final ValueNotifier<double> remainingDistance = ValueNotifier(0.0);
  static final ValueNotifier<double> remainingDuration = ValueNotifier(0.0);

  // States
  static StreamSubscription<geo.Position>? _positionSubscription;
  static PolylineAnnotationManager? _polylineManager;
  static PolylineAnnotation? _routeAnnotation;
  static int _currentStepIndex = 0;
  static bool _hasAnnouncedCurrentStep = false;
  static bool _recenterToggle = false;
  static List<Offset>? _routePoints;
  static List<double>? _routeDistances;
  static double _routeOriginLat = 0.0;
  static double _routeOriginLng = 0.0;
  static double _metersPerDegreeLat = 0.0;
  static double _metersPerDegreeLng = 0.0;
  static int _trimSegmentIndex = 0;
  static double _trimmedDistance = 0.0;
  static const double _maxTrimDeviationMeters = 50.0;
  static const double _offRouteDeviationMeters = 50.0;
  static const int _offRouteSamplesForReroute = 3;
  static const Duration _rerouteCooldown = Duration(seconds: 10);
  static int _offRouteSamples = 0;
  static bool _isRerouting = false;
  static DateTime? _lastRerouteAt;

  // Methods
  static Future<void> startNavigation(PinnedLocation destination) async {
    isLoading.value = true;

    try {
      final currentPos = await LocationService.getCurrentLocation();
      final route = await DirectionsService.getDrivingRoute(
        originLat: currentPos.latitude,
        originLng: currentPos.longitude,
        destLat: destination.latitude,
        destLng: destination.longitude,
      );

      if (route == null) {
        throw Exception('No driving route found');
      }

      activeRoute.value = route;
      remainingDistance.value = route.distance;
      remainingDuration.value = route.duration;
      _currentStepIndex = 0;
      _hasAnnouncedCurrentStep = false;
      _offRouteSamples = 0;
      _lastRerouteAt = null;

      if (route.steps.isNotEmpty) {
        currentStep.value = route.steps.first;
      }

      _prepareRouteGeometry(route);
      await _renderRoute(route);
      isNavigating.value = true;
      recenterCamera();

      if (route.steps.isNotEmpty) {
        await NavigationAudioService.announce(route.steps.first);
        _hasAnnouncedCurrentStep = true;
      }

      NavigationVoiceService.startCommentary();

      _startPositionTracking(destination);
    } finally {
      isLoading.value = false;
    }
  }

  static void recenterCamera() {
    _recenterToggle = !_recenterToggle;
    MapController.viewportController?.moveTo(
      FollowPuckViewportState(
        zoom: _recenterToggle ? 17.5 : 17.5001,
        pitch: 50.0,
        bearing: const FollowPuckViewportStateBearingHeading(),
      ),
      transition: const DefaultViewportTransition(
        maxDuration: Duration(milliseconds: 800),
      ),
    );
  }

  static Future<void> stopNavigation() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    await NavigationVoiceService.stopCommentary();

    await _clearRoute();

    isNavigating.value = false;
    activeRoute.value = null;
    currentStep.value = null;
    remainingDistance.value = 0.0;
    remainingDuration.value = 0.0;
    _currentStepIndex = 0;
    _hasAnnouncedCurrentStep = false;
    _routePoints = null;
    _routeDistances = null;
    _trimSegmentIndex = 0;
    _trimmedDistance = 0.0;
    _offRouteSamples = 0;
    _isRerouting = false;
    _lastRerouteAt = null;

    MapController.viewportController?.moveTo(
      FollowPuckViewportState(
        zoom: 16,
        pitch: 0,
        bearing: const FollowPuckViewportStateBearingConstant(0),
      ),
      transition: const DefaultViewportTransition(
        maxDuration: Duration(milliseconds: 800),
      ),
    );
  }

  static void _startPositionTracking(PinnedLocation destination) {
    _positionSubscription?.cancel();

    _positionSubscription =
        geo.Geolocator.getPositionStream(
          locationSettings: const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((position) {
          _onPositionUpdate(position, destination);
        });
  }

  static void _onPositionUpdate(geo.Position currentPosition, PinnedLocation destination) {
    final route = activeRoute.value;
    if (route == null || route.steps.isEmpty) return;

    final deviation = _updateRouteTrim(currentPosition);

    final distanceToDest = geo.Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      destination.latitude,
      destination.longitude,
    );
    remainingDistance.value = distanceToDest;

    if (distanceToDest < 20.0) {
      final arrivalStep = route.steps.lastWhere(
        (s) => s.type?.toLowerCase() == 'arrive',
        orElse: () => route.steps.last,
      );
      NavigationAudioService.announce(arrivalStep);
      stopNavigation();
      return;
    }

    _trackOffRoute(currentPosition, destination, deviation);

    if (_currentStepIndex < route.steps.length) {
      final targetStep = route.steps[_currentStepIndex];
      final distanceToManeuver = geo.Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        targetStep.location.lat.toDouble(),
        targetStep.location.lng.toDouble(),
      );

      if (!_hasAnnouncedCurrentStep && distanceToManeuver <= 100.0) {
        NavigationAudioService.announce(targetStep);
        _hasAnnouncedCurrentStep = true;
      }

      if (distanceToManeuver <= 25.0) {
        _currentStepIndex++;
        _hasAnnouncedCurrentStep = false;
        if (_currentStepIndex < route.steps.length) {
          currentStep.value = route.steps[_currentStepIndex];
        }
      }
    }
  }

  static Future<void> _renderRoute(NavigationRoute route) async {
    final map = MapController.map.value;
    if (map == null) return;

    _polylineManager ??= await map.annotations
        .createPolylineAnnotationManager();
    if (_routeAnnotation != null) {
      await _polylineManager?.delete(_routeAnnotation!);
      _routeAnnotation = null;
    }

    _routeAnnotation = await _polylineManager?.create(
      PolylineAnnotationOptions(
        geometry: LineString(coordinates: route.geometry),
        lineColor: const Color(0xFF1A73E8).toARGB32(),
        lineWidth: 6.5,
        lineJoin: LineJoin.ROUND,
      ),
    );

    // Trim color is the only way to grey out the traveled line; Mapbox still
    // marks it experimental, but trim offset is stable and already in use.
    // ignore: experimental_member_use
    await _polylineManager?.setLineTrimColor(
      const Color(0xFF9AA0A6).toARGB32(),
    );
    await _polylineManager?.setLineTrimOffset(<double?>[0.0, 0.0]);
  }

  static void _prepareRouteGeometry(NavigationRoute route) {
    final geometry = route.geometry;
    _routePoints = null;
    _routeDistances = null;
    _trimSegmentIndex = 0;
    _trimmedDistance = 0.0;
    if (geometry.length < 2) return;

    final origin = geometry.first;
    _routeOriginLat = origin.lat.toDouble();
    _routeOriginLng = origin.lng.toDouble();
    _metersPerDegreeLat = 110574.0;
    _metersPerDegreeLng = 111320.0 * math.cos(_routeOriginLat * math.pi / 180);

    final points = geometry
        .map(
          (point) => Offset(
            (point.lng.toDouble() - _routeOriginLng) * _metersPerDegreeLng,
            (point.lat.toDouble() - _routeOriginLat) * _metersPerDegreeLat,
          ),
        )
        .toList();

    final distances = List<double>.filled(points.length, 0.0);
    for (var i = 1; i < points.length; i++) {
      distances[i] = distances[i - 1] + (points[i] - points[i - 1]).distance;
    }

    _routePoints = points;
    _routeDistances = distances;
  }

  static double? _updateRouteTrim(geo.Position position) {
    final points = _routePoints;
    final distances = _routeDistances;
    if (points == null || distances == null || points.length < 2) return null;

    final totalDistance = distances.last;
    if (totalDistance <= 0) return null;

    final target = Offset(
      (position.longitude - _routeOriginLng) * _metersPerDegreeLng,
      (position.latitude - _routeOriginLat) * _metersPerDegreeLat,
    );

    var nearestDeviation = double.infinity;
    var nearestAlong = _trimmedDistance;
    var nearestIndex = _trimSegmentIndex;
    for (var i = _trimSegmentIndex; i < points.length - 1; i++) {
      final start = points[i];
      final segment = points[i + 1] - start;
      final segmentLengthSquared =
          segment.dx * segment.dx + segment.dy * segment.dy;
      if (segmentLengthSquared == 0) continue;

      final toTarget = target - start;
      final t =
          ((toTarget.dx * segment.dx + toTarget.dy * segment.dy) /
                  segmentLengthSquared)
              .clamp(0.0, 1.0);
      final deviation = (target - (start + segment * t)).distance;
      if (deviation >= nearestDeviation) continue;

      nearestDeviation = deviation;
      nearestIndex = i;
      nearestAlong = distances[i] + (distances[i + 1] - distances[i]) * t;
    }

    if (!nearestDeviation.isFinite) return null;

    final manager = _polylineManager;
    if (manager == null ||
        nearestDeviation > _maxTrimDeviationMeters ||
        nearestAlong <= _trimmedDistance) {
      return nearestDeviation;
    }

    _trimSegmentIndex = nearestIndex;
    _trimmedDistance = nearestAlong;
    manager.setLineTrimOffset(<double?>[0.0, nearestAlong / totalDistance]);
    return nearestDeviation;
  }

  static void _trackOffRoute(geo.Position position, PinnedLocation destination, double? deviation) {
    if (deviation == null || _isRerouting) return;

    if (deviation <= _offRouteDeviationMeters) {
      _offRouteSamples = 0;
      return;
    }

    _offRouteSamples++;
    if (_offRouteSamples < _offRouteSamplesForReroute) return;

    // Mapbox bills each Directions request, so reroutes are rate-limited.
    final lastRerouteAt = _lastRerouteAt;
    if (lastRerouteAt != null &&
        DateTime.now().difference(lastRerouteAt) < _rerouteCooldown) {
      return;
    }

    _offRouteSamples = 0;
    unawaited(_reroute(position, destination));
  }

  static Future<void> _reroute(geo.Position position, PinnedLocation destination) async {
    _isRerouting = true;
    _lastRerouteAt = DateTime.now();
    final routeBeingReplaced = activeRoute.value;

    try {
      // Await the scolding so the reroute's first maneuver prompt does not
      // cut it off; it names the turn the driver was supposed to make.
      await NavigationAudioService.announceWrongTurn(currentStep.value);

      final route = await DirectionsService.getDrivingRoute(
        originLat: position.latitude,
        originLng: position.longitude,
        destLat: destination.latitude,
        destLng: destination.longitude,
      );
      // Navigation may have stopped or restarted while the request was in flight.
      if (route == null ||
          !isNavigating.value ||
          !identical(activeRoute.value, routeBeingReplaced)) {
        return;
      }

      activeRoute.value = route;
      remainingDistance.value = route.distance;
      remainingDuration.value = route.duration;
      _currentStepIndex = 0;
      _hasAnnouncedCurrentStep = false;
      currentStep.value = route.steps.isNotEmpty ? route.steps.first : null;

      _prepareRouteGeometry(route);
      await _renderRoute(route);

      if (!isNavigating.value) {
        await _clearRoute();
        return;
      }

      await _announceUpcomingManeuver(route);
    } catch (error) {
      debugPrint('[Navigation] Reroute failed: $error');
    } finally {
      _isRerouting = false;
    }
  }

  static Future<void> _announceUpcomingManeuver(NavigationRoute route) async {
    if (route.steps.isEmpty) return;

    final step = route.steps.firstWhere((candidate) {
      final modifier = candidate.modifier?.toLowerCase() ?? '';
      return modifier.contains('left') || modifier.contains('right');
    }, orElse: () => route.steps.first);
    await NavigationAudioService.announce(step);
  }

  static Future<void> _clearRoute() async {
    final manager = _polylineManager;
    final annotation = _routeAnnotation;
    if (manager != null && annotation != null) {
      await manager.delete(annotation);
    }
    _routeAnnotation = null;
  }
}
