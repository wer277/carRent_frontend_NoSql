import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  final VehicleService service;

  const EditVehicleScreen({
    Key? key,
    required this.vehicle,
    required this.service,
  }) : super(key: key);

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _productionYearController;
  late TextEditingController _locationController;
  late TextEditingController _dailyPriceController;
  String _selectedStatus = 'Dostępny';

  final List<String> _statusOptions = [
    'Zarezerwowany',
    'Dostępny',
    'W naprawie',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.vehicle.brand);
    _modelController = TextEditingController(text: widget.vehicle.model);
    _productionYearController =
        TextEditingController(text: widget.vehicle.productionYear.toString());
    _locationController = TextEditingController(text: widget.vehicle.location);
    _dailyPriceController =
        TextEditingController(text: widget.vehicle.dailyPrice.toString());
    _selectedStatus = widget.vehicle.status;
  }

  Future<void> _updateVehicle() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        await widget.service.updateVehicle(widget.vehicle.id, {
          'brand': _brandController.text.trim(),
          'model': _modelController.text.trim(),
          'productionYear': int.parse(_productionYearController.text.trim()),
          'location': _locationController.text.trim(),
          'dailyPrice': double.parse(_dailyPriceController.text.trim()),
          'status': _selectedStatus,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle updated successfully')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update vehicle: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _productionYearController.dispose();
    _locationController.dispose();
    _dailyPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Vehicle'),
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
          children: [
            _buildTextField(_brandController, 'Brand', Icons.car_rental),
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
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Vehicle',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
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
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
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
