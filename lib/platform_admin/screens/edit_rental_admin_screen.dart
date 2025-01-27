import 'package:flutter/material.dart';
import '../services/platform_admin_service.dart';
import '../models/rental_admin_model.dart';

class EditRentalAdminScreen extends StatefulWidget {
  final RentalAdmin admin;
  final RentalAdminService service;

  const EditRentalAdminScreen({
    Key? key,
    required this.admin,
    required this.service,
  }) : super(key: key);

  @override
  State<EditRentalAdminScreen> createState() => _EditRentalAdminScreenState();
}

class _EditRentalAdminScreenState extends State<EditRentalAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;
  String? _password;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.admin.name);
    _surnameController = TextEditingController(text: widget.admin.surname);
    _emailController = TextEditingController(text: widget.admin.email);
  }

  void _updateRentalAdmin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      _formKey.currentState?.save();

      Map<String, dynamic> updateData = {
        'name': _nameController.text,
        'surname': _surnameController.text,
        'email': _emailController.text,
      };

      if (_password != null && _password!.isNotEmpty) {
        updateData['password'] = _password;
      }

      try {
        await widget.service.updateRentalAdmin(
          widget.admin.id, 
          updateData,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin data updated successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update failed: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    String? initialValue,
    TextInputType? keyboardType,
    bool obscureText = false,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      initialValue: initialValue,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onSaved: onSaved,
      validator: validator,
      style: const TextStyle(fontSize: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edycja profilu rental_admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/tloListView.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildTextField(
                                label: 'Name',
                                icon: Icons.person_outline,
                                initialValue: _nameController.text,
                                onSaved: (value) =>
                                    _nameController.text = value ?? '',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Name is required';
                                  }
                                  if (value.length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Surname',
                                icon: Icons.person,
                                initialValue: _surnameController.text,
                                onSaved: (value) =>
                                    _surnameController.text = value ?? '',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Surname is required';
                                  }
                                  if (value.length < 2) {
                                    return 'Surname must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Email',
                                icon: Icons.email_outlined,
                                initialValue: _emailController.text,
                                keyboardType: TextInputType.emailAddress,
                                onSaved: (value) =>
                                    _emailController.text = value ?? '',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Adres e-mail jest wymagany';
                                  }
                                  final emailRegex = RegExp(
                                    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                                  );
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Proszę podać prawidłowy adres e-mail';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'New Password',
                                icon: Icons.lock_outline,
                                obscureText: true,
                                onSaved: (value) => _password = value,
                                validator: (value) {
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateRentalAdmin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Zapisz zmiany',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
