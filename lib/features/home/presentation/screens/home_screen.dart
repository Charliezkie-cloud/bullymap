import 'package:bullymap/features/home/controllers/map_controller.dart';
import 'package:bullymap/features/home/presentation/widgets/main_map.dart';
import 'package:bullymap/features/home/presentation/widgets/map_action_buttons.dart';
import 'package:bullymap/features/home/presentation/widgets/map_search_bar.dart';
import 'package:flutter/material.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  // States
  bool _isLoadingLocation = false;

  // Methods
  Future<void> _recenterMap() async {
    setState(() => _isLoadingLocation = true);

    try {
      await MapController.goToCurrentLocation();
    } catch (e) {
      debugPrint('Location error: $e');

      if (!mounted) return;

      _showPermissionDialog();
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _showPermissionDialog() {
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
  
  // Widget methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MainMap(onPermissionPermanentlyDenied: _showPermissionDialog),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
              child: const MapSearchBar(),
            )
          ),
        ]
      ),
      floatingActionButtonLocation: .endFloat,
      floatingActionButton: Align(
        alignment: .bottomRight,
        child: MapActionButtons(
          onRecenter: _recenterMap,
          onDirections: () => debugPrint('Directions pressed'),
          isLoading: _isLoadingLocation
        ),
      ),
    );
  }
}