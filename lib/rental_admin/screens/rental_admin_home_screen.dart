import 'package:flutter/material.dart';

class RentalAdminHomeScreen extends StatelessWidget {
  const RentalAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Admin Home'),
      ),
      body: const Center(
        child: Text('Welcome to Rental Admin Home Screen'),
      ),
    );
  }
} 