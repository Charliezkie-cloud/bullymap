import 'package:bullymap/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';

class ThemeSwitch extends StatefulWidget {
  const ThemeSwitch({ super.key });

  // Widget methods
  @override
  State<StatefulWidget> createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  // Widget methods
  @override
  Widget build(BuildContext context) {
    return Switch(
      value: ThemeController.themeMode.value == ThemeMode.dark,
      onChanged: ThemeController.toggleTheme
    );
  }
}