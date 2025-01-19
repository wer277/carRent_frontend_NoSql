import 'package:flutter/material.dart';
import '../services/vehicle_service.dart';

class CreateVehicleScreen extends StatefulWidget {
  final VehicleService service;
  final String rentalCompanyId;

  const CreateVehicleScreen({
    Key? key,
    required this.service,
    required this.rentalCompanyId,
  }) : super(key: key);

  @override
  State<CreateVehicleScreen> createState() => _CreateVehicleScreenState();
}

class _CreateVehicleScreenState extends State<CreateVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _productionYearController = TextEditingController();
  final _locationController = TextEditingController();
  final _dailyPriceController = TextEditingController();

  String _selectedStatus = 'Dostępny';

  final List<String> _statusOptions = [
    'Zarezerwowany',
    'Dostępny',
    'W naprawie',
  ];

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _productionYearController.dispose();
    _locationController.dispose();
    _dailyPriceController.dispose();
    super.dispose();
  }

  Future<void> _createVehicle() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        await widget.service.createVehicle({
          'brand': _brandController.text.trim(),
          'model': _modelController.text.trim(),
          'productionYear': int.parse(_productionYearController.text.trim()),
          'location': _locationController.text.trim(),
          'dailyPrice': double.parse(_dailyPriceController.text.trim()),
          'status': _selectedStatus,
          'rentalCompanyId': widget.rentalCompanyId,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create vehicle: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Vehicle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_brandController, 'Brand', Icons.directions_car),
            const SizedBox(height: 16),
            _buildTextField(_modelController, 'Model', Icons.directions_car),
            const SizedBox(height: 16),
            _buildTextField(
                _productionYearController, 'Production Year', Icons.date_range,
                isNumeric: true),
            const SizedBox(height: 16),
            _buildTextField(_locationController, 'Location', Icons.location_on),
            const SizedBox(height: 16),
            _buildTextField(
                _dailyPriceController, 'Daily Price', Icons.attach_money,
                isNumeric: true),
            const SizedBox(height: 16),
            _buildDropdownField('Status', Icons.info),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _createVehicle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Create Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) return '$label is required';
        return null;
      },
    );
  }

  Widget _buildDropdownField(String label, IconData icon) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          items: _statusOptions.map((String status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedStatus = newValue!;
            });
          },
        ),
      ),
    );
  }
}
