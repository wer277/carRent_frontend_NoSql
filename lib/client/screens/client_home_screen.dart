import 'package:flutter/material.dart';
import 'package:carrent_frontend/rental_admin/screens/navigation_menu_rental_admin.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Home'),
      ),
      body: const Center(
        child: Text('Welcome to Client Home Screen'),
      ),
    );
  }
} 