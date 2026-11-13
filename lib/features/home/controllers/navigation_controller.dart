import 'dart:async';

import 'package:bullymap/core/services/location_service.dart';
import 'package:bullymap/features/home/controllers/map_controller.dart';
import 'package:bullymap/features/home/data/services/directions_service.dart';
import 'package:bullymap/features/home/data/services/navigation_audio_service.dart';
import 'package:bullymap/features/home/models/navigation_route.dart';
import 'package:bullymap/features/home/models/navigation_step.dart';
import 'package:bullymap/features/home/models/pinned_location.dart';
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

      if (route.steps.isNotEmpty) {
        currentStep.value = route.steps.first;
      }

      await _renderRoute(route);
      isNavigating.value = true;
      recenterCamera();

      if (route.steps.isNotEmpty) {
        await NavigationAudioService.announce(route.steps.first);
        _hasAnnouncedCurrentStep = true;
      }

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

    await _clearRoute();

    isNavigating.value = false;
    activeRoute.value = null;
    currentStep.value = null;
    remainingDistance.value = 0.0;
    remainingDuration.value = 0.0;
    _currentStepIndex = 0;
    _hasAnnouncedCurrentStep = false;

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

  static void _onPositionUpdate(
    geo.Position currentPosition,
    PinnedLocation destination,
  ) {
    final route = activeRoute.value;
    if (route == null || route.steps.isEmpty) return;

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
