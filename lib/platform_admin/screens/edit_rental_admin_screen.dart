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
  String? _password; // Nowa zmienna na nowe hasło
  bool _isLoading = false;

  void _updateRentalAdmin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      _formKey.currentState?.save();

      // Przygotowanie danych do aktualizacji
      Map<String, dynamic> updateData = {
        'name': _name,
        'surname': _surname,
        'email': _email,
      };

      // Dodaj hasło do danych, jeśli zostało wprowadzone
      if (_password != null && _password!.isNotEmpty) {
        updateData['password'] = _password;
      }

      try {
        await widget.service.updateRentalAdmin(
          widget.rentalAdminId,
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
          // Tło z grafiką i przezroczystością
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
          // Zawartość formularza
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
                                initialValue: _name,
                                onSaved: (value) => _name = value,
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
                                initialValue: _surname,
                                onSaved: (value) => _surname = value,
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
                                initialValue: _email,
                                keyboardType: TextInputType.emailAddress,
                                onSaved: (value) => _email = value,
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
                                initialValue: null,
                                obscureText: true,
                                onSaved: (value) => _password = value,
                                validator: (value) {
                                  // Hasło jest opcjonalne
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
}
