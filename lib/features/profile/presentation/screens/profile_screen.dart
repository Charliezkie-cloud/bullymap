import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String title;

  const ProfileScreen({
    super.key,
    required this.title
  });

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text("This is the profile screen"),
      ),
    );
  }
}