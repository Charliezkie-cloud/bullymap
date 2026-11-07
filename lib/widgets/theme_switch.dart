import 'package:bullymap/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';

class ThemeSwitch extends StatefulWidget {
  const ThemeSwitch({ super.key });

  @override
  State<StatefulWidget> createState() {
    return _ThemeSwitchState();
  }
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  @override
  Widget build(BuildContext context) {
    return Switch(
      value: ThemeController.themeMode.value == ThemeMode.dark,
      onChanged: ThemeController.toggleTheme
    );
  }
}