import 'package:bullymap/app/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationScreen extends StatefulWidget {
  final String title;
  
  const NavigationScreen({
    super.key,
    required this.title
  });

  @override
  State<StatefulWidget> createState() {
    return _NavigationScreenState();
  }
}

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text("This is the navigation screen"),
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
              onPressed: () => context.push(Routes.settings),
              child: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      )
    );
  }
}