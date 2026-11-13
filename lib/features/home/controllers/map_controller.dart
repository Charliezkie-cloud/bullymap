import 'package:bullymap/core/services/location_service.dart';
import 'package:bullymap/features/home/models/pinned_location.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapController {
  // Constants
  static final ValueNotifier<MapboxMap?> map = ValueNotifier(null);
  static final ValueNotifier<Point?> pinnedPoint = ValueNotifier(null);

  // States
  static ViewportController? viewportController;

  // Methods
  static void clearPin() => pinnedPoint.value = null;
  
  static Future<void> Function(Point point, {PinnedLocation? location})? dropPin;

  static Future<void> goToCurrentLocation({ double zoom = 16, double pitch = 0 }) async {
    final position = await LocationService.getCurrentLocation();
    final currentMap = map.value;
    final controller = viewportController;

    if (currentMap == null || controller == null) return;

    controller.moveTo(
      CameraViewportState(
        center: Point(
          coordinates: Position(
            position.longitude,
            position.latitude,
          ),
        ),
        zoom: zoom,
        pitch: pitch,
      ),
      transition: const FlyViewportTransition(
        duration: Duration(milliseconds: 1000),
      ),
    );
  }
}