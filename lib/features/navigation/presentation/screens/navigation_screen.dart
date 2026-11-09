import 'package:bullymap/app/routes.dart';
import 'package:bullymap/widgets/navigation_floating_buttons.dart';
import 'package:flutter/material.dart';

class NavigationScreen extends StatefulWidget {
  final String title;
  
  const NavigationScreen({
    super.key,
    required this.title
  });

  @override
  State<StatefulWidget> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text("This is the navigation screen"),
      ),
      floatingActionButtonLocation: .centerFloat,
      floatingActionButton: const NavigationFloatingButtons(pushRoute: Routes.settings)
    );
  }
}