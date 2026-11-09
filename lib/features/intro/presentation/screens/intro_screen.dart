import 'package:bullymap/app/routes.dart';
import 'package:bullymap/widgets/navigation_floating_buttons.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  final String title;
  
  const IntroScreen({
    super.key,
    required this.title
  });

  @override
  State<StatefulWidget> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text("This is the intro screen")
          ],
        ),
      ),
      floatingActionButtonLocation: .centerFloat,
      floatingActionButton: const NavigationFloatingButtons(pushRoute: Routes.home, hasPrevious: false)
    );
  }
}