import 'package:bullymap/app/routes.dart';
import 'package:bullymap/features/home/presentation/widgets/main_map.dart';
import 'package:bullymap/widgets/navigation_floating_buttons.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  
  const HomeScreen({
    super.key,
    required this.title
  });

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // States

  
  // Widget methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MainMap()
        ]
      ),
      floatingActionButtonLocation: .centerFloat,
      floatingActionButton: const NavigationFloatingButtons(pushRoute: Routes.navigation)
    );
  }
}