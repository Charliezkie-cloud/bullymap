import 'package:bullymap/app/routes.dart';
import 'package:bullymap/widgets/navigation_floating_buttons.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final String title;
  
  const SettingsScreen({
    super.key,
    required this.title
  });

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text("This is the settings screen"),
      ),
      floatingActionButtonLocation: .centerFloat,
      floatingActionButton: const NavigationFloatingButtons(pushRoute: Routes.intro)
    );
  }
}