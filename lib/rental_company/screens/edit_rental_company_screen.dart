import 'package:flutter/material.dart';
import '../models/rental_company_model.dart';
import '../services/rental_company_service.dart';

class EditRentalCompanyScreen extends StatefulWidget {
  final RentalCompany rentalCompany;
  final RentalCompanyService service;

  const EditRentalCompanyScreen({
    Key? key,
    required this.rentalCompany,
    required this.service,
  }) : super(key: key);

  @override
  State<EditRentalCompanyScreen> createState() =>
      _EditRentalCompanyScreenState();
}

class _EditRentalCompanyScreenState extends State<EditRentalCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _phone;
  String? _address;
  String? _policy;
  bool _isLoading = false;

  void _updateRentalCompany() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      _formKey.currentState?.save();

      // Przygotowanie danych do aktualizacji
      Map<String, dynamic> updateData = {
        'name': _name,
        'contactEmail': _email,
        'contactPhone': _phone,
        'address': _address,
        'rentalPolicy': _policy,
      };

      try {
        await widget.service.updateRentalCompany(
          widget.rentalCompany.id,
          updateData,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rental company updated successfully'),
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
          'Edycja wypożyczalni',
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
                                icon: Icons.business,
                                initialValue: widget.rentalCompany.name,
                                onSaved: (value) => _name = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Contact Email',
                                icon: Icons.email_outlined,
                                initialValue: widget.rentalCompany.contactEmail,
                                keyboardType: TextInputType.emailAddress,
                                onSaved: (value) => _email = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Contact Email is required';
                                  }
                                  final emailRegex = RegExp(
                                    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                                  );
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Contact Phone',
                                icon: Icons.phone,
                                initialValue: widget.rentalCompany.contactPhone,
                                keyboardType: TextInputType.phone,
                                onSaved: (value) => _phone = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Contact Phone is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Address',
                                icon: Icons.location_on,
                                initialValue: widget.rentalCompany.address,
                                onSaved: (value) => _address = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Address is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Rental Policy',
                                icon: Icons.description_outlined,
                                initialValue: widget.rentalCompany.rentalPolicy,
                                maxLines: 3,
                                onSaved: (value) => _policy = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Rental Policy is required';
                                  }
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
                          onPressed: _isLoading ? null : _updateRentalCompany,
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
    int maxLines = 1,
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
      maxLines: maxLines,
      onSaved: onSaved,
      validator: validator,
      style: const TextStyle(fontSize: 16),
    );
  }
}
