import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/vehicle_service.dart';
import '../models/vehicle_model.dart';
import '../widgets/vehicle_item.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_message.dart';
import 'edit_vehicle_screen.dart';

class VehicleListScreen extends StatefulWidget {
  final VehicleService service;

  const VehicleListScreen({Key? key, required this.service}) : super(key: key);

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  late Future<List<Vehicle>> _vehicles;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    setState(() {
      _vehicles = widget.service.getVehicles();
    });
  }

  void _deleteVehicle(String id) async {
    try {
      await widget.service.deleteVehicle(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle deleted successfully')),
      );
      _loadVehicles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete vehicle: $e')),
      );
    }
  }

  Future<String?> _getRentalCompanyIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final rentalCompanyIdsJson = prefs.getString('rentalCompanyIds');
    if (rentalCompanyIdsJson == null) return null;

    try {
      final decoded = json.decode(rentalCompanyIdsJson);
      final List<dynamic> idsDynamic = decoded;
      if (idsDynamic.isNotEmpty) {
        return idsDynamic.first.toString();
      }
    } catch (e) {
      debugPrint('Error decoding rentalCompanyIds: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista Pojazdów',
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
          FutureBuilder<List<Vehicle>>(
            future: _vehicles,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              } else if (snapshot.hasError) {
                return ErrorMessage(
                  message: 'Failed to load vehicles: ${snapshot.error}',
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Brak pojazdów. Dodaj nowy pojazd z poziomu menu.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                final vehicles = snapshot.data!;
                return ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return VehicleItem(
                      vehicle: vehicle,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditVehicleScreen(
                              vehicle: vehicle,
                              service: widget.service,
                            ),
                          ),
                        ).then((value) {
                          if (value == true) {
                            _loadVehicles();
                          }
                        });
                      },
                      onDelete: () => _deleteVehicle(vehicle.id),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
