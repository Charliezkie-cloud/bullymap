import 'package:bullymap/widgets/app_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigationScaffold extends StatelessWidget {
  // Constants
  final StatefulNavigationShell navigationShell;
  
  const MainNavigationScaffold({
    super.key,
    required this.navigationShell,
  });

  // Methods
  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  // Widget methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}