import 'package:bullymap/core/theme/theme_controller.dart';
import 'package:bullymap/features/home/controllers/map_controller.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MainMap extends StatefulWidget {
  final VoidCallback onPermissionPermanentlyDenied;
  
  const MainMap({
    super.key,
    required this.onPermissionPermanentlyDenied
  });

  @override
  State<StatefulWidget> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> with WidgetsBindingObserver {
  // States
  final ViewportController _viewportController = ViewportController();
  bool _hasCentered = false;
  
  // Methods
  void _onMapCreated(MapboxMap map) {
    MapController.map.value = map;

    map.scaleBar.updateSettings(.new(enabled: false));
    
    _updateMapTheme();
    _requestLocationPermission();
  }

  void _updateMapTheme() {
    final themeMode = ThemeController.themeMode.value;
    final isDarkPlatformBrightness = themeMode == ThemeMode.system && WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    final isDark = themeMode == .dark || isDarkPlatformBrightness;

    MapController.map.value?.loadStyleURI(isDark ? MapboxStyles.DARK : MapboxStyles.STANDARD);
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;

    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    if (!mounted) return;

    if (status.isGranted) {
      await _enableLocation();
    } else if (status.isPermanentlyDenied) {
      widget.onPermissionPermanentlyDenied();
    }
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;

    if (!mounted) return;

    if (status.isGranted) {
      await _enableLocation();
    }
  }

  Future<void> _enableLocation() async {
    await MapController.map.value?.location.updateSettings(
      LocationComponentSettings(enabled: true),
    );

    if (!mounted || _hasCentered) return;
    _hasCentered = true;

    _viewportController.moveTo(
      FollowPuckViewportState(
        zoom: 16,
        pitch: 0,
        bearing: FollowPuckViewportStateBearingConstant(0),
      ),
      transition: const DefaultViewportTransition(maxDuration: .new(seconds: 1)),
    );
  }

  // Widget methods
  @override
  void didChangePlatformBrightness() {
    _updateMapTheme();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    ThemeController.themeMode.addListener(_updateMapTheme);
    MapController.viewportController = _viewportController;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ThemeController.themeMode.removeListener(_updateMapTheme);
    MapController.viewportController = null;
    _viewportController.dispose();

    super.dispose();
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
      onMapCreated: _onMapCreated
    );
  }
}