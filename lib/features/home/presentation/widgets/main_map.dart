import 'package:bullymap/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MainMap extends StatefulWidget {
  const MainMap({ super.key });

  @override
  State<StatefulWidget> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> with WidgetsBindingObserver {
  // States
  MapboxMap? _map;

  final num _longitude = 123.8854;
  final num _latitude = 10.3157;
  
  // Map methods
  void _onMapCreated(MapboxMap map) {
    _map = map;

    map.scaleBar.updateSettings(.new(enabled: false));
    _updateMapTheme();
  }

  void _updateMapTheme() {
    final themeMode = ThemeController.themeMode.value;
    final isDarkPlatformBrightness = themeMode == ThemeMode.system && WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    final isDark = themeMode == .dark || isDarkPlatformBrightness;

    _map?.loadStyleURI(isDark ? MapboxStyles.DARK : MapboxStyles.STANDARD);
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ThemeController.themeMode.removeListener(_updateMapTheme);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      styleUri: MapboxStyles.STANDARD,
      viewport: CameraViewportState(
        center: .new(coordinates: .new(_longitude, _latitude)),
        zoom: 12,
        pitch: 0,
        bearing: 0
      ),
      onMapCreated: _onMapCreated
    );
  }
}