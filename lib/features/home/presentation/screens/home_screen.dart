import 'package:bullymap/features/home/controllers/map_controller.dart';
import 'package:bullymap/features/home/controllers/navigation_controller.dart';
import 'package:bullymap/features/home/data/services/location_search_service.dart';
import 'package:bullymap/features/home/data/models/location_suggestion.dart';
import 'package:bullymap/features/home/data/models/pinned_location.dart';
import 'package:bullymap/features/home/presentation/widgets/location_details_sheet.dart';
import 'package:bullymap/features/home/presentation/widgets/main_map.dart';
import 'package:bullymap/features/home/presentation/widgets/map_action_buttons.dart';
import 'package:bullymap/features/home/presentation/widgets/map_search_bar.dart';
import 'package:bullymap/features/home/presentation/widgets/map_search_result_sheet.dart';
import 'package:bullymap/features/home/presentation/widgets/navigation_hud.dart';
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
  bool _isLocationSheetFromSearch = false;

  // Methods
  void _onSearchResults(List<LocationSuggestion> results) {
    setState(() {
      _searchResults = results;
      _showSearchResults = true;
      _isLoadingPlace = false;
      _showLocationSheet = false;
    });
  }

  Future<PinnedLocation?> _onLocationSelected(PinnedLocation location) async {
    final point = Point(coordinates: Position(location.longitude, location.latitude));
    final pinnedLocation = MapController.dropPin(point, location: location);

    // The viewport controller stays in FollowPuckViewportState after the
    // initial location fix, so map.easeTo alone gets overridden on the next
    // puck update. Move the controller to keep the pin in view.
    MapController.viewportController?.moveTo(
      CameraViewportState(center: point, zoom: 16),
      transition: const FlyViewportTransition(
        duration: Duration(milliseconds: 1000),
      ),
    );

    return pinnedLocation;
  }

  void _onMapPinned(PinnedLocation location) {
    setState(() {
      _selectedLocation = location;
      _showLocationSheet = true;
      _isLoadingPlace = false;
      _showSearchResults = false;
    });
  }

  void _onStartNavigation(PinnedLocation location) {
    setState(() {
      _showLocationSheet = false;
      _showSearchResults = false;
    });

    NavigationController.startNavigation(location);
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

  void _onPinLoading() {
    setState(() {
      _showLocationSheet = true;
      _isLoadingPlace = true;
      _selectedLocation = null;
      _isLocationSheetFromSearch = false;
    });
  }

  Future<void> _onCloseLocationSheet() async {
    setState(() {
      _showLocationSheet = false;
      _showSearchResults = _isLocationSheetFromSearch;
      _isLocationSheetFromSearch = false;
    });

    await MapController.clearPin();
  }

  void _onSearchFocusChanged(bool hasFocus) {
    if (!hasFocus) return;

    setState(() {
      _showSearchResults = false;
      _showLocationSheet = false;
    });
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

  Future<void> _onSearchResultTapped(LocationSuggestion suggestion) async {
    final openedFromSearchResults = _showSearchResults;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _showSearchResults = false);

    _onPinLoading();
    _isLocationSheetFromSearch = openedFromSearchResults;

    try {
      final location = await LocationSearchService.retrieve(suggestion.mapboxId);
      if (!mounted) return;

      final pinnedLocation = await _onLocationSelected(location);
      if (!mounted || pinnedLocation == null) return;

      _onMapPinned(pinnedLocation);
    } catch (e) {
      debugPrint('Retrieve error: $e');
      if (!mounted) return;

      setState(() {
        _showLocationSheet = false;
        _isLoadingPlace = false;
        _isLocationSheetFromSearch = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load place. Try again.')),
      );
    }
  }

  Future<void> _onRecenter() async {
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

  Future<void> _onCompassPressed() async {
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: .expand,
        children: [
          Positioned.fill(
            child: MainMap(
              onPermissionPermanentlyDenied: _showLocationPermissionDialog,
              onCameraChanged: _onCameraChanged,
              onPinLoading: _onPinLoading,
              onMapPinned: _onMapPinned,
            )
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
              child: MapSearchBar(
                onSuggestionSelected: _onSearchResultTapped,
                onSearchResults: _onSearchResults,
                onSearchFocusChanged: _onSearchFocusChanged,
                isSheetOpen: _showSearchResults || _showLocationSheet,
              ),
            )
          ),

          Positioned(
            right: 16,
            bottom: keyboardHeight + 16,
            child:  AnimatedSlide(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              offset: _showLocationSheet || _showSearchResults || NavigationController.isNavigating.value ? const Offset(1.5, 0) : Offset.zero,
              child: IgnorePointer(
                ignoring: _showLocationSheet || _showSearchResults,
                child: MapActionButtons(
                  onCompassPressed: _onCompassPressed,
                  onRecenterPressed: _onRecenter,
                  mapBearing: _mapBearing,
                  showCompass: _showCompass,
                  isLoadingLocation: _isLoadingLocation,
                ),
              ),
            ),
          ),

          AnimatedSlide(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            offset: _showSearchResults ? Offset.zero : const Offset(0, 1),
            child: IgnorePointer(
              ignoring: !_showSearchResults,
              child: DraggableScrollableSheet(
                initialChildSize: 0.50,
                minChildSize: 0.50,
                maxChildSize: 0.50,
                snap: true,
                builder: (context, scrollController) {
                  return MapSearchResultSheet(
                    suggestions: _searchResults,
                    scrollController: scrollController,
                    onClose: () => setState(() => _showSearchResults = false),
                    onSelected: _onSearchResultTapped
                  );
                },
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
                initialChildSize: 0.40,
                minChildSize: 0.40,
                maxChildSize: 0.50,
                snap: true,
                snapSizes: const [0.40, 0.50],
                builder: (context, scrollController) {
                  return LocationDetailsSheet(
                    location: _selectedLocation,
                    isLoading: _isLoadingPlace,
                    scrollController: scrollController,
                    onClose: _onCloseLocationSheet,
                    onStartNavigation: _onStartNavigation,
                  );
                },
              ),
            ),
          ),

          const NavigationHud(),
        ]
      )
    );
  }
}
