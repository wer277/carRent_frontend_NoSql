import 'package:flutter/material.dart';
import '../services/client_vehicle_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientCompleteProfileScreen extends StatefulWidget {
  final ClientVehicleService service;

  const ClientCompleteProfileScreen({Key? key, required this.service})
      : super(key: key);

  @override
  _ClientCompleteProfileScreenState createState() =>
      _ClientCompleteProfileScreenState();
}

class _ClientCompleteProfileScreenState
    extends State<ClientCompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? surname;
  String? phoneNumber;
  String? city;
  String? street;
  String? houseNumber;
  String? postalCode;

  bool isLoading = false;

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    try {
      await widget.service.completeProfile({
        'name': name,
        'surname': surname,
        'phoneNumber': phoneNumber,
        'city': city,
        'street': street,
        'houseNumber': houseNumber,
        'postalCode': postalCode,
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isProfileComplete', true);
      Navigator.pushReplacementNamed(context, 'ClientHome');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uzupełnij profil'),
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
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
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
                              _buildTextField('Imię', Icons.person,
                                  (value) => name = value),
                              const SizedBox(height: 16),
                              _buildTextField('Nazwisko', Icons.person,
                                  (value) => surname = value),
                              const SizedBox(height: 16),
                              _buildTextField('Telefon', Icons.phone,
                                  (value) => phoneNumber = value),
                              const SizedBox(height: 16),
                              _buildTextField('Miasto', Icons.location_city,
                                  (value) => city = value),
                              const SizedBox(height: 16),
                              _buildTextField('Ulica', Icons.streetview,
                                  (value) => street = value),
                              const SizedBox(height: 16),
                              _buildTextField('Numer domu', Icons.home,
                                  (value) => houseNumber = value),
                              const SizedBox(height: 16),
                              _buildTextField(
                                  'Kod pocztowy',
                                  Icons.local_post_office,
                                  (value) => postalCode = value),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _submitProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Zapisz',
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

  Widget _buildTextField(
      String label, IconData icon, Function(String?) onSaved) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
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
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      onSaved: onSaved,
      validator: (value) =>
          value == null || value.isEmpty ? 'Pole wymagane' : null,
    );
  }
}
