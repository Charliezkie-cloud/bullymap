import 'package:bullymap/features/home/controllers/map_controller.dart';
import 'package:bullymap/features/home/presentation/widgets/main_map.dart';
import 'package:bullymap/features/home/presentation/widgets/map_action_buttons.dart';
import 'package:bullymap/features/home/presentation/widgets/map_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  
  const HomeScreen({
    super.key,
    required this.title
  });

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {  
  // States
  bool _isLoadingLocation = false;
  bool _wasKeyboardVisible = false;
  double _mapBearing = 0;
  bool _showCompass = false;

  // Methods
  Future<void> _recenterMap() async {
    setState(() => _isLoadingLocation = true);

    try {
      await MapController.goToCurrentLocation();
    } catch (e) {
      debugPrint('Location error: $e');

      if (!mounted) return;

      _showLocationPermissionDialog();
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'BullyMap needs access to your location to show your '
            'current position on the map. Please enable location '
            'permission in your application settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _onMapSearch(Map<String, dynamic> feature) {
    final coordinates = feature['geometry']['coordinates'];

    final longitude = (coordinates[0] as num).toDouble();
    final latitude = (coordinates[1] as num).toDouble();

    MapController.viewportController?.moveTo(
      CameraViewportState(
        center: Point(
          coordinates: Position(longitude, latitude),
        ),
        zoom: 16,
      ),
      transition: const FlyViewportTransition(
        duration: Duration(milliseconds: 1000),
      ),
    );
  }

  Future<void> _onCameraChanged(CameraChangedEventData data,) async {
    final map = MapController.map.value;

    if (map == null) return;
    final cameraState = await map.getCameraState();

    if (!mounted) return;
    final bearing = cameraState.bearing;

    setState(() {
      _mapBearing = bearing;
      _showCompass = bearing.abs() > 0.5;
    });
  }

  Future<void> _resetCompass() async {
    final map = MapController.map.value;

    if (map == null) return;

    await map.easeTo(
      CameraOptions(bearing: 0),
      MapAnimationOptions(duration: 500)
    );
  }

  // Widget methods
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    final isKeyboardVisible = View.of(context).viewInsets.bottom > 0;

    if (_wasKeyboardVisible && !isKeyboardVisible) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    _wasKeyboardVisible = isKeyboardVisible;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: .expand,
        children: [
          Positioned.fill(
            child: MainMap(
              onPermissionPermanentlyDenied: _showLocationPermissionDialog,
              onCameraChangedListener: _onCameraChanged,
            )
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
              child: MapSearchBar(onLocationSelected: _onMapSearch),
            )
          ),

          Positioned(
            right: 16,
            bottom: keyboardHeight + 16,
            child: MapActionButtons(
              onRecenter: _recenterMap,
              onDirections: () => debugPrint('Directions pressed'),
              isLoading: _isLoadingLocation,

              onCompassPressed: _resetCompass,
              bearing: _mapBearing,
              showCompass: _showCompass
            ),
          ),
        ]
      )
    );
  }
}