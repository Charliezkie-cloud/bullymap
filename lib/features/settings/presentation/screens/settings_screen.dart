import 'package:bullymap/app/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  final String title;
  
  const SettingsScreen({
    super.key,
    required this.title
  });

  @override
  State<StatefulWidget> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text("This is the settings screen"),
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
              onPressed: () => context.go(Routes.intro),
              child: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      )
    );
  }
}