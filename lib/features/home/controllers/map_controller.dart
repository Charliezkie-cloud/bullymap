import 'dart:typed_data';

import 'package:bullymap/core/constants/app_assets.dart';
import 'package:bullymap/core/services/location_service.dart';
import 'package:bullymap/core/theme/theme_controller.dart';
import 'package:bullymap/core/utils/svg_utils.dart';
import 'package:bullymap/features/home/data/models/pinned_location.dart';
import 'package:bullymap/features/home/data/services/geocode_service.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapController {
  // Constants
  static final ValueNotifier<MapboxMap?> map = ValueNotifier(null);
  static final ValueNotifier<Point?> pinnedPoint = ValueNotifier(null);
  static final Future<Uint8List> _pinImage = SvgUtils.svgToPng(AppAssets.mapPin, width: 32, height: 32);
  static final Future<Uint8List> _navigationPuckImage = SvgUtils.svgToPng(AppAssets.navigationPuck, width: 28, height: 28);

  // States
  static ViewportController? viewportController;
  static PointAnnotationManager? _pinManager;
  static PointAnnotation? _pin;
  static int _geocodingRequestId = 0;
  static bool _hasCenteredOnUser = false;

  // Methods
  static void updateMapTheme() {
    final themeMode = ThemeController.themeMode.value;
    final isDarkPlatformBrightness = themeMode == ThemeMode.system && WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    final isDark = themeMode == .dark || isDarkPlatformBrightness;

    map.value?.loadStyleURI(isDark ? MapboxStyles.DARK : MapboxStyles.STANDARD);
  }

  static Future<void> handleStyleLoaded() async {
    final currentMap = map.value;
    if (currentMap == null) return;

    _pinManager ??= await currentMap.annotations.createPointAnnotationManager();

    final point = pinnedPoint.value;
    if (point != null && _pin == null) {
      await _renderPin(point);
    }
  }

  static Future<PinnedLocation?> dropPin(Point point, {PinnedLocation? location}) async {
    final requestId = ++_geocodingRequestId;
    final latitude = point.coordinates.lat.toDouble();
    final longitude = point.coordinates.lng.toDouble();

    pinnedPoint.value = point;

    await _renderPin(point);
    await map.value?.easeTo(
      CameraOptions(center: point, zoom: 16),
      MapAnimationOptions(duration: 300),
    );

    if (location != null) {
      return requestId == _geocodingRequestId ? location : null;
    }

    try {
      final resolvedLocation = await GeocodeService.reverseGeocode(latitude: latitude, longitude: longitude);
      if (requestId != _geocodingRequestId) return null;

      return resolvedLocation ?? PinnedLocation(
        name: 'Dropped pin',
        address: 'No address available',
        latitude: latitude,
        longitude: longitude,
      );
    } catch (error) {
      if (requestId != _geocodingRequestId) return null;

      debugPrint('Reverse geocoding failed: $error');
      return PinnedLocation(
        name: 'Dropped pin',
        address: 'Unable to retrieve address',
        latitude: latitude,
        longitude: longitude,
      );
    }
  }

  static Future<void> clearPin() async {
    final manager = _pinManager;
    final pin = _pin;

    if (manager != null && pin != null) {
      await manager.delete(pin);
    }

    _pin = null;
    pinnedPoint.value = null;
  }

  static Future<PermissionStatus> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;

    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isGranted) {
      await _enableLocationTracking();
    }

    return status;
  }

  static Future<void> refreshLocationTracking() async {
    final status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      await _enableLocationTracking();
    }
  }

  static Future<void> _enableLocationTracking() async {
    final puckImage = await _navigationPuckImage;

    await map.value?.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        puckBearingEnabled: true,
        puckBearing: PuckBearing.HEADING,
        locationPuck: LocationPuck(
          locationPuck2D: LocationPuck2D(
            bearingImage: puckImage,
            shadowImage: Uint8List(0),
            topImage: Uint8List(0),
          ),
        ),
      ),
    );

    final controller = viewportController;
    if (controller == null || _hasCenteredOnUser) return;
    _hasCenteredOnUser = true;

    controller.moveTo(
      FollowPuckViewportState(
        zoom: 16,
        pitch: 0,
        bearing: FollowPuckViewportStateBearingConstant(0),
      ),
      transition: const DefaultViewportTransition(maxDuration: .new(seconds: 1)),
    );
  }

  static Future<void> _renderPin(Point point) async {
    final manager = _pinManager;

    if (manager == null) return;
    if (_pin != null) {
      await manager.delete(_pin!);
      _pin = null;
    }

    _pin = await manager.create(
      PointAnnotationOptions(
        geometry: point,
        image: await _pinImage,
        iconSize: 0.5,
        iconAnchor: IconAnchor.BOTTOM,
      ),
    );
  }

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

  static void dispose() {
    map.value = null;
    pinnedPoint.value = null;
    viewportController = null;
    _pinManager = null;
    _pin = null;
    _geocodingRequestId++;
    _hasCenteredOnUser = false;
  }
}
