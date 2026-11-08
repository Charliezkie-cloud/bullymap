import "dart:io";

import "package:bullymap/app/app.dart";
import "package:bullymap/core/config/env.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:mapbox_maps_flutter/mapbox_maps_flutter.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (defaultTargetPlatform == .android || defaultTargetPlatform == .iOS) {
    Env.validate();
    MapboxOptions.setAccessToken(Env.mapBoxAccessToken);
  }

  runApp(const MainApp());
}