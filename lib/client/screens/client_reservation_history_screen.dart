import 'package:flutter/material.dart';
import '../services/client_vehicle_service.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_message.dart';
import '../widgets/client_reservation_item.dart';
import '../models/reservation.model.dart'; // Import modelu ReservationView

class ClientReservationHistoryScreen extends StatefulWidget {
  final ClientVehicleService service;

  const ClientReservationHistoryScreen({Key? key, required this.service})
      : super(key: key);

  @override
  State<ClientReservationHistoryScreen> createState() =>
      _ClientReservationHistoryScreenState();
}

class _ClientReservationHistoryScreenState
    extends State<ClientReservationHistoryScreen> {
  late Future<List<ReservationView>> _reservations;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  void _loadReservations() {
    setState(() {
      _reservations =
          widget.service.getReservedVehicles().then((reservationsJson) {
        // Zakładamy, że getReservedVehicles() zwraca listę map JSON
        return reservationsJson
            .map<ReservationView>((json) => ReservationView.fromJson(json))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historia rezerwacji',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Warstwa tła z obrazkiem
          Center(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/tloListView.png', // ścieżka do obrazka w tle
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          FutureBuilder<List<ReservationView>>(
            future: _reservations,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              } else if (snapshot.hasError) {
                return ErrorMessage(
                  message:
                      'Nie udało się załadować rezerwacji: ${snapshot.error}',
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Brak rezerwacji.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                );
              } else {
                final reservations = snapshot.data!;
                return ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    return ClientReservationItem(
                      vehicle: reservation.vehicle,
                      startDate: reservation.startDate,
                      endDate: reservation.endDate,
                      onCancel: () async {
                        try {
                          debugPrint(
                              'Anulowanie rezerwacji ID: ${reservation.reservationId}');
                          await widget.service
                              .cancelReservation(reservation.reservationId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Rezerwacja została anulowana!')),
                          );
                          _loadReservations();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Błąd anulowania: $e')),
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
