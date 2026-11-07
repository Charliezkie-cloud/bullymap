import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(.system);

  static void toggleTheme(bool isDark) {
    themeMode.value = isDark ? .dark : .light;
  }
}