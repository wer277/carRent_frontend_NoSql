import 'package:flutter/material.dart';
import '../services/client_vehicle_service.dart';
import '../../vehicle/models/vehicle_model.dart';
import '../widgets/client_vehicle_item.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_message.dart';

class ClientVehicleListScreen extends StatefulWidget {
  final ClientVehicleService service;

  const ClientVehicleListScreen({Key? key, required this.service})
      : super(key: key);

  @override
  State<ClientVehicleListScreen> createState() =>
      _ClientVehicleListScreenState();
}

class _ClientVehicleListScreenState extends State<ClientVehicleListScreen> {
  late Future<List<Vehicle>> _vehicles;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    setState(() {
      _vehicles = widget.service.getAllVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wszystkie dostępne samochody',
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
                  message: 'Nie udało się załadować danych: ${snapshot.error}',
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Brak dostępnych samochodów.',
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
                    return ClientVehicleItem(
                      vehicle: vehicle,
                      onReserve: () async {
                        final startDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );

                        if (startDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Wybór daty rozpoczęcia anulowany')),
                          );
                          return;
                        }

                        final endDate = await showDatePicker(
                          context: context,
                          initialDate: startDate.add(const Duration(days: 1)),
                          firstDate: startDate,
                          lastDate:
                              DateTime.now().add(const Duration(days: 730)),
                        );

                        if (endDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Wybór daty zakończenia anulowany')),
                          );
                          return;
                        }

                        try {
                          await widget.service
                              .reserveVehicle(vehicle.id, startDate, endDate);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Pojazd został zarezerwowany!')),
                          );
                          _loadVehicles();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Błąd rezerwacji: $e')),
                          );
                        }
                      },
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
