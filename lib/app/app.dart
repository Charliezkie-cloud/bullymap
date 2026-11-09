import 'package:bullymap/app/router.dart';
import 'package:bullymap/core/theme/dark_theme.dart';
import 'package:bullymap/core/theme/light_theme.dart';
import 'package:bullymap/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';

class MainApp extends StatelessWidget {
  const MainApp({ super.key });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeController.themeMode,
      builder: (context, value, child) {
        return MaterialApp.router(
          title: "Bully Map",
          theme: LightTheme.theme,
          darkTheme: DarkTheme.theme,
          themeMode: value,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        );
      }
    );
  }
}