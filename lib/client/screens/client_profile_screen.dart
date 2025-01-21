import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/client_vehicle_service.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_message.dart';

class ClientProfileScreen extends StatefulWidget {
  final ClientVehicleService service;

  const ClientProfileScreen({Key? key, required this.service})
      : super(key: key);

  @override
  _ClientProfileScreenState createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  late Future<Map<String, dynamic>> _clientFuture;

  @override
  void initState() {
    super.initState();
    _loadClientData();
  }

  void _loadClientData() {
    setState(() {
      _clientFuture = widget.service.getClientProfile();
    });
  }

  Future<void> _navigateToEditProfile(Map<String, dynamic> client) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditClientProfileScreen(
          service: widget.service,
          clientData: client,
        ),
      ),
    );

    if (result == true) {
      _loadClientData();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, 'Login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Klienta',
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
          FutureBuilder<Map<String, dynamic>>(
            future: _clientFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              } else if (snapshot.hasError) {
                return ErrorMessage(
                    message:
                        'Nie udało się załadować danych: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return const Center(
                    child: Text('Nie znaleziono danych klienta'));
              } else {
                final client = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                  'Imię', client['name'] ?? 'Nie podano'),
                              Divider(
                                  color: Theme.of(context).colorScheme.primary),
                              _buildInfoRow('Nazwisko',
                                  client['surname'] ?? 'Nie podano'),
                              Divider(
                                  color: Theme.of(context).colorScheme.primary),
                              _buildInfoRow('Email', client['email']),
                              Divider(
                                  color: Theme.of(context).colorScheme.primary),
                              _buildInfoRow('Telefon',
                                  client['phoneNumber'] ?? 'Nie podano'),
                              Divider(
                                  color: Theme.of(context).colorScheme.primary),
                              _buildInfoRow(
                                  'Miasto', client['city'] ?? 'Nie podano'),
                              Divider(
                                  color: Theme.of(context).colorScheme.primary),
                              _buildInfoRow(
                                  'Ulica', client['street'] ?? 'Nie podano'),
                              Divider(
                                  color: Theme.of(context).colorScheme.primary),
                              _buildInfoRow('Kod pocztowy',
                                  client['postalCode'] ?? 'Nie podano'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _navigateToEditProfile(client),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Edytuj profil',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Wyloguj',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class EditClientProfileScreen extends StatefulWidget {
  final ClientVehicleService service;
  final Map<String, dynamic> clientData;

  const EditClientProfileScreen({
    Key? key,
    required this.service,
    required this.clientData,
  }) : super(key: key);

  @override
  _EditClientProfileScreenState createState() => _EditClientProfileScreenState();
}

class _EditClientProfileScreenState extends State<EditClientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _streetController;
  late TextEditingController _houseNumberController;
  late TextEditingController _postalCodeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.clientData['name'] ?? '');
    _surnameController = TextEditingController(text: widget.clientData['surname'] ?? '');
    _phoneController = TextEditingController(text: widget.clientData['phoneNumber'] ?? '');
    _cityController = TextEditingController(text: widget.clientData['city'] ?? '');
    _streetController = TextEditingController(text: widget.clientData['street'] ?? '');
    _houseNumberController = TextEditingController(text: widget.clientData['houseNumber'] ?? '');
    _postalCodeController = TextEditingController(text: widget.clientData['postalCode'] ?? '');
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await widget.service.updateClientProfile({
          'name': _nameController.text,
          'surname': _surnameController.text,
          'phoneNumber': _phoneController.text,
          'city': _cityController.text,
          'street': _streetController.text,
          'houseNumber': _houseNumberController.text,
          'postalCode': _postalCodeController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil zaktualizowany pomyślnie')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się zaktualizować profilu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj profil'),
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
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _surnameController,
                          label: 'Nazwisko',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Telefon',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _cityController,
                          label: 'Miasto',
                          icon: Icons.location_city,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _streetController,
                          label: 'Ulica',
                          icon: Icons.streetview,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _houseNumberController,
                          label: 'Numer domu',
                          icon: Icons.home,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _postalCodeController,
                          label: 'Kod pocztowy',
                          icon: Icons.local_post_office,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Zapisz zmiany',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        suffixIcon: suffixIcon,
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
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'To pole jest wymagane';
        }
        return null;
      },
      style: const TextStyle(fontSize: 16),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }
}
