import 'package:bullymap/core/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapController {
  static final ValueNotifier<MapboxMap?> map = ValueNotifier(null);

  static ViewportController? viewportController;

  static Future<void> goToCurrentLocation() async {
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
        zoom: 16,
      ),
      transition: const FlyViewportTransition(
        duration: Duration(milliseconds: 1000),
      ),
    );
  }
}