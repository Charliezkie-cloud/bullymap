import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapController {
  static final ValueNotifier<MapboxMap?> map = ValueNotifier(null);
}