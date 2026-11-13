import 'package:bullymap/features/home/controllers/map_controller.dart';
import 'package:bullymap/features/home/data/services/location_search_service.dart';
import 'package:bullymap/features/home/models/location_suggestion.dart';
import 'package:bullymap/features/home/models/pinned_location.dart';
import 'package:bullymap/features/home/presentation/widgets/location_details_sheet.dart';
import 'package:bullymap/features/home/presentation/widgets/main_map.dart';
import 'package:bullymap/features/home/presentation/widgets/map_action_buttons.dart';
import 'package:bullymap/features/home/presentation/widgets/map_search_bar.dart';
import 'package:bullymap/features/home/presentation/widgets/map_search_result_sheet.dart';
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
  List<LocationSuggestion> _searchResults = [];
  PinnedLocation? _selectedLocation;
  double _mapBearing = 0;
  bool _isLoadingLocation = false;
  bool _wasKeyboardVisible = false;
  bool _showCompass = false;
  bool _isLoadingPlace = false;
  bool _showLocationSheet = false;
  bool _showSearchResults = false;

  // Methods
  void _onMapSearchBarResults(List<LocationSuggestion> result) {
    setState(() {
      _searchResults = result;
      _showSearchResults = true;
      _isLoadingPlace = false;
      _showLocationSheet = false;
    });
  }

  void _onMapSearchBarSelected(PinnedLocation location) {
    setState(() => _searchResults = []);
    final point = Point(coordinates: Position(location.longitude, location.latitude),);

    MapController.dropPin?.call(point, location: location);
    MapController.viewportController?.moveTo(
      CameraViewportState(center: point, zoom: 16),
      transition: const FlyViewportTransition(
        duration: Duration(milliseconds: 1000),
      ),
    );
  }

  void _onLocationSelected(PinnedLocation location) {
    setState(() {
      _selectedLocation = location;
      _isLoadingPlace = false;
      _showLocationSheet = true;
      _showSearchResults = false;
      _searchResults.clear();
    });
  }

  void _startNavigation(PinnedLocation location) {
    debugPrint('Navigate to ${location.name}');
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

  void _onLocationLoading() {
    setState(() {
      _showLocationSheet = true;
      _isLoadingPlace = true;
      _selectedLocation = null;
    });
  }

  void _closeLocationSheet() {
    setState(() => _showLocationSheet = false);
    MapController.clearPin();
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

  Future<void> _onSuggestionTapped(LocationSuggestion suggestion) async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _searchResults = [];
      _showSearchResults = false;
    });

    _onLocationLoading();

    try {
      final location = await LocationSearchService.retrieve(suggestion.mapboxId);
      if (!mounted) return;

      _onMapSearchBarSelected(location);
      _onLocationSelected(location);
    } catch (e) {
      debugPrint('Retrieve error: $e');
      if (!mounted) return;

      setState(() {
        _showLocationSheet = false;
        _isLoadingPlace = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load place. Try again.')),
      );
    }
  }

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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
              onLocationLoading: _onLocationLoading,
              onLocationSelected: _onLocationSelected,
            )
          ),

          AnimatedSlide(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            offset: _showSearchResults
                ? Offset.zero
                : const Offset(0, 1),
            child: IgnorePointer(
              ignoring: !_showSearchResults,
              child: DraggableScrollableSheet(
                initialChildSize: 0.50,
                minChildSize: 0.50,
                maxChildSize: 0.75,
                snap: true,
                snapSizes: const [0.50, 0.75],
                builder: (context, scrollController) {
                  return MapSearchResultSheet(
                    suggestions: _searchResults,
                    scrollController: scrollController,
                    onClose: () => setState(() => _showSearchResults = false),
                    onSelected: _onSuggestionTapped,
                  );
                },
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
              child: MapSearchBar(
                onLocationSelected: _onMapSearchBarSelected,
                onMapSearchBarResults: _onMapSearchBarResults,
              ),
            )
          ),

          Positioned(
            right: 16,
            bottom: keyboardHeight + 16,
            child:  AnimatedSlide(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              offset: _showLocationSheet || _showSearchResults ? const Offset(1.5, 0) : Offset.zero,
              child: IgnorePointer(
                ignoring: _showLocationSheet || _showSearchResults,
                child: MapActionButtons(
                  onRecenter: _recenterMap,
                  onDirections: () => debugPrint('Directions pressed'),
                  isLoading: _isLoadingLocation,
                  onCompassPressed: _resetCompass,
                  bearing: _mapBearing,
                  showCompass: _showCompass,
                ),
              ),
            ),
          ),

          AnimatedSlide(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            offset: _showLocationSheet ? Offset.zero : const Offset(0, 1),
            child: IgnorePointer(
              ignoring: !_showLocationSheet,
              child: DraggableScrollableSheet(
                initialChildSize: 0.41,
                minChildSize: 0.41,
                maxChildSize: 0.50,
                snap: true,
                snapSizes: const [0.41, 0.50],
                builder: (context, scrollController) {
                  return LocationDetailsSheet(
                    location: _selectedLocation,
                    isLoading: _isLoadingPlace,
                    scrollController: scrollController,
                    onClose: _closeLocationSheet,
                    onStartNavigation: _startNavigation,
                  );
                },
              ),
            ),
          ),
        ]
      )
    );
  }
}