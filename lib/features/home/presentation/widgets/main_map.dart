import 'package:bullymap/core/constants/app_assets.dart';
import 'package:bullymap/core/theme/theme_controller.dart';
import 'package:bullymap/core/utils/svg_utils.dart';
import 'package:bullymap/features/home/controllers/map_controller.dart';
import 'package:bullymap/features/home/data/services/geocode_service.dart';
import 'package:bullymap/features/home/models/pinned_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MainMap extends StatefulWidget {
  // Constants
  final ValueChanged<PinnedLocation> onLocationSelected;
  final VoidCallback onPermissionPermanentlyDenied;
  final VoidCallback onLocationLoading;
  final OnCameraChangeListener onCameraChangedListener;
  
  const MainMap({
    super.key,
    required this.onPermissionPermanentlyDenied,
    required this.onCameraChangedListener,
    required this.onLocationLoading,
    required this.onLocationSelected
  });

  // Widget methods
  @override
  State<StatefulWidget> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> with WidgetsBindingObserver {
  // Constants
  final ViewportController _viewportController = ViewportController();
  
  // States
  PointAnnotationManager? _pinManager;
  PointAnnotation? _pin;
  Future<Uint8List>? _pinImage;
  Future<Uint8List>? _navigationPuckImage;
  bool _hasCentered = false;
  int _geocodingRequestId = 0;
  
  // Methods
  void _onMapCreated(MapboxMap map) {
    MapController.map.value = map;

    map.scaleBar.updateSettings(.new(enabled: false));
    map.compass.updateSettings(CompassSettings(enabled: false));
    map.addInteraction(LongTapInteraction.onMap((context) => _dropPin(context.point)));
    
    _updateMapTheme();
    _requestLocationPermission();
  }

  void _updateMapTheme() {
    final themeMode = ThemeController.themeMode.value;
    final isDarkPlatformBrightness = themeMode == ThemeMode.system && WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    final isDark = themeMode == .dark || isDarkPlatformBrightness;

    MapController.map.value?.loadStyleURI(isDark ? MapboxStyles.DARK : MapboxStyles.STANDARD);
  }

  void _clearPin() async {
    final manager = _pinManager;
    final pin = _pin;

    if (manager != null && pin != null) {
      await manager.delete(pin);
    }

    _pin = null;
    MapController.pinnedPoint.value = null;
  }

  void _onPinnedPointChanged() {
    if (MapController.pinnedPoint.value == null) _clearPin();
  }

  Future<void> _dropPin(Point point, {PinnedLocation? location}) async {
    HapticFeedback.mediumImpact();

    final requestId = ++_geocodingRequestId;
    final latitude = point.coordinates.lat.toDouble();
    final longitude = point.coordinates.lng.toDouble();

    MapController.pinnedPoint.value = point;
    if (location == null) widget.onLocationLoading();

    await _renderPin(point);
    await MapController.map.value?.easeTo(
      CameraOptions(center: point, zoom: 16),
      MapAnimationOptions(duration: 300),
    );

    if (location != null) {
      if (!mounted || requestId != _geocodingRequestId) return;
      widget.onLocationSelected(location);
      return;
    }

    try {
      final location = await GeocodeService.reverseGeocode(latitude: latitude, longitude: longitude);

      if (!mounted || requestId != _geocodingRequestId) return;

      widget.onLocationSelected(
        location ?? PinnedLocation(
          name: 'Dropped pin',
          address: 'No address available',
          latitude: latitude,
          longitude: longitude,
        ),
      );
    } catch (error) {
      if (!mounted || requestId != _geocodingRequestId) return;

      debugPrint('Reverse geocoding failed: $error');
      widget.onLocationSelected(
        PinnedLocation(
          name: 'Dropped pin',
          address: 'Unable to retrieve address',
          latitude: latitude,
          longitude: longitude,
        ),
      );
    }
  }

  Future<void> _renderPin(Point point) async {
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

  Future<void> _onStyleLoaded(StyleLoadedEventData _) async {
    final map = MapController.map.value;
    if (map == null) return;

    _pinManager ??= await map.annotations.createPointAnnotationManager();

    final point = MapController.pinnedPoint.value;

    if (point != null && _pin == null) {
      await _renderPin(point);
    }
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
    final puckImage = await _navigationPuckImage;

    await MapController.map.value?.location.updateSettings(
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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    ThemeController.themeMode.addListener(_updateMapTheme);
    MapController.viewportController = _viewportController;
    MapController.pinnedPoint.addListener(_onPinnedPointChanged);

    _pinImage = SvgUtils.svgToPng(AppAssets.mapPin, width: 32, height: 32);
    _navigationPuckImage = SvgUtils.svgToPng(AppAssets.mapPin, width: 28, height: 28);
    MapController.dropPin = _dropPin;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ThemeController.themeMode.removeListener(_updateMapTheme);
    MapController.pinnedPoint.removeListener(_onPinnedPointChanged);
    
    MapController.viewportController = null;
    MapController.dropPin = null;

    _viewportController.dispose();
    super.dispose();
  }
  
  @override
  void didChangePlatformBrightness() {
    _updateMapTheme();
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
      onCameraChangeListener: widget.onCameraChangedListener
    );
  }
}