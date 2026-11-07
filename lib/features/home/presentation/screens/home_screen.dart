import 'package:bullymap/app/routes.dart';
import 'package:bullymap/widgets/theme_switch.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  
  const HomeScreen({
    super.key,
    required this.title
  });

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _count = 0;

  void _incrementCounter() {
    setState(() {
      _count++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _count--;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text("$_count", style: Theme.of(context).textTheme.displayLarge),
            SizedBox(height: 16),
            const Text("Hello world ;D"),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: .center,
              children: [
                TextButton(onPressed: _decrementCounter, child: const Text("Decrement")),
                SizedBox(width: 16),
                ElevatedButton(onPressed: _incrementCounter, child: const Text("Increment"))
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: .center,
              children: [
                const Text("Theme Switch"),
                SizedBox(width: 16),
                ThemeSwitch()
              ],
            )
          ],
        ),
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
              onPressed: () => context.push(Routes.navigation),
              child: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      )
    );
  }
}