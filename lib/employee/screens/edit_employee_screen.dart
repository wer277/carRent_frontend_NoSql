// screens/edit_employee_screen.dart
import 'package:flutter/material.dart';
import '../../rental_company/services/rental_company_service.dart';
import '../models/employee_model.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_message.dart';

class EditEmployeeScreen extends StatefulWidget {
  final RentalCompanyService service;
  final Employee employee;

  const EditEmployeeScreen({
    Key? key,
    required this.service,
    required this.employee,
  }) : super(key: key);

  @override
  _EditEmployeeScreenState createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicjalizacja kontrolerów z danymi pracownika
    _nameController = TextEditingController(text: widget.employee.firstName);
    _surnameController = TextEditingController(text: widget.employee.lastName);
    _emailController = TextEditingController(text: widget.employee.email);
    _passwordController = TextEditingController();
  }

  Future<void> _updateEmployee() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Przygotowanie danych do aktualizacji
      Map<String, dynamic> updateData = {
        'name': _nameController.text,
        'surname': _surnameController.text,
        'email': _emailController.text,
      };
      if (_passwordController.text.isNotEmpty) {
        updateData['password'] = _passwordController.text;
      }

      try {
        // Wywołanie metody aktualizacji pracownika na podstawie jego ID
        await widget.service.updateEmployee(widget.employee.id, updateData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Dane pracownika zaktualizowane pomyślnie')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się zaktualizować danych: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
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
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj pracownika'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Tło z grafiką
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
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Imię',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Proszę wprowadzić imię';
                            }
                            if (value.length < 2) {
                              return 'Imię musi mieć co najmniej 2 znaki';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _surnameController,
                          label: 'Nazwisko',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Proszę wprowadzić nazwisko';
                            }
                            if (value.length < 2) {
                              return 'Nazwisko musi mieć co najmniej 2 znaki';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Proszę wprowadzić email';
                            }
                            if (!value.contains('@')) {
                              return 'Proszę wprowadzić poprawny adres email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Nowe hasło',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) {
                            // Hasło jest opcjonalne, brak dodatkowej walidacji
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateEmployee,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
