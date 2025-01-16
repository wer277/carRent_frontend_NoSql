import 'package:flutter/material.dart';
import '../services/rental_admin_service.dart';

class EditRentalAdminScreen extends StatefulWidget {
  final String rentalAdminId;
  final RentalAdminService service;

  const EditRentalAdminScreen({
    Key? key,
    required this.rentalAdminId,
    required this.service,
  }) : super(key: key);

  @override
  State<EditRentalAdminScreen> createState() => _EditRentalAdminScreenState();
}

class _EditRentalAdminScreenState extends State<EditRentalAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _surname;
  String? _email;

  void _updateRentalAdmin() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        await widget.service.updateRentalAdmin(
          widget.rentalAdminId,
          {
            'name': _name,
            'surname': _surname,
            'email': _email,
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rental admin updated successfully')),
        );
        Navigator.of(context).pop(); // Powrót do poprzedniego ekranu
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update rental admin: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Rental Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                initialValue: _name,
                onSaved: (value) => _name = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Surname'),
                initialValue: _surname,
                onSaved: (value) => _surname = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Surname is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                initialValue: _email,
                onSaved: (value) => _email = value,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Valid email is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateRentalAdmin,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
