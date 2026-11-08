import 'package:bullymap/app/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  
  const HomeScreen({
    super.key,
    required this.title
  });

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  // SAMPLE LNG AND LATITUDE (Will be deleted or removed during development.)
  final num _longitude = 123.8854;
  final num _latitude = 10.3157;

  void _onMapCreated(MapboxMap map) {
    map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        viewport: CameraViewportState(
          center: Point(coordinates: Position(_longitude, _latitude)),
          zoom: 12,
          pitch: 0,
          bearing: 0
        ),
        onMapCreated: _onMapCreated,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              heroTag: 'fab-left',
              onPressed: () => context.pop(),
              child: const Icon(Icons.arrow_back),
            ),
            FloatingActionButton(
              heroTag: 'fab-right',
              onPressed: () => context.push(Routes.navigation),
              child: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      )
    );
  }
}