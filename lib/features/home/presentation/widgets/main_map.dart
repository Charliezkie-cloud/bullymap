import 'package:bullymap/core/theme/theme_controller.dart';
import 'package:bullymap/features/home/controllers/map_controller.dart';
import 'package:bullymap/features/home/data/models/pinned_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MainMap extends StatefulWidget {
  // Constants
  final ValueChanged<PinnedLocation> onMapPinned;
  final VoidCallback onPermissionPermanentlyDenied;
  final VoidCallback onPinLoading;
  final OnCameraChangeListener onCameraChanged;

  const MainMap({
    super.key,
    required this.onPermissionPermanentlyDenied,
    required this.onCameraChanged,
    required this.onPinLoading,
    required this.onMapPinned,
  });

  // Widget methods
  @override
  State<StatefulWidget> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> with WidgetsBindingObserver {
  // Constants
  final ViewportController _viewportController = ViewportController();

  // Methods
  void _onMapCreated(MapboxMap map) {
    MapController.map.value = map;

    map.scaleBar.updateSettings(.new(enabled: false));
    map.compass.updateSettings(CompassSettings(enabled: false));
    map.addInteraction(LongTapInteraction.onMap(_onMapLongPressed));

    MapController.updateMapTheme();
    _requestLocationPermission();
  }

  Future<void> _onMapLongPressed(MapContentGestureContext context) async {
    HapticFeedback.mediumImpact();
    widget.onPinLoading();

    final location = await MapController.dropPin(context.point);

    if (!mounted || location == null) return;
    widget.onMapPinned(location);
  }

  Future<void> _onStyleLoaded(StyleLoadedEventData _) => MapController.handleStyleLoaded();

  Future<void> _requestLocationPermission() async {
    final status = await MapController.requestLocationPermission();

    if (!mounted || !status.isPermanentlyDenied) return;
    widget.onPermissionPermanentlyDenied();
  }

  Future<void> _checkLocationPermission() => MapController.refreshLocationTracking();

  // Widget methods
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    ThemeController.themeMode.addListener(MapController.updateMapTheme);
    MapController.viewportController = _viewportController;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ThemeController.themeMode.removeListener(MapController.updateMapTheme);

    MapController.dispose();
    _viewportController.dispose();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    MapController.updateMapTheme();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      styleUri: MapboxStyles.STANDARD,
      viewport: CameraViewportState(zoom: 11, pitch: 0, bearing: 0),
      viewportController: _viewportController,
      onMapCreated: _onMapCreated,
      onStyleLoadedListener: _onStyleLoaded,
      onCameraChangeListener: widget.onCameraChanged
    );
  }
}
