import 'package:flutter/material.dart';

class PlatformAdminHomeScreen extends StatelessWidget {
  const PlatformAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Admin Home'),
      ),
      body: const Center(
        child: Text('Welcome to Platform Admin Home Screen'),
      ),
    );
  }
}
