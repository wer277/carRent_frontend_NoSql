import 'package:flutter/material.dart';
import '../../vehicle/models/vehicle_model.dart';

class ClientReservationItem extends StatelessWidget {
  final Vehicle vehicle;
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onCancel;

  const ClientReservationItem({
    Key? key,
    required this.vehicle,
    required this.startDate,
    required this.endDate,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wyświetlamy przycisk tylko, jeśli obecna data jest przed datą rozpoczęcia rezerwacji
    // i status nie jest "Anulowany" lub "Dostępny"
    final showCancelButton = DateTime.now().isBefore(startDate) &&
        vehicle.status != 'Anulowany' &&
        vehicle.status != 'Dostępny';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          '${vehicle.brand} ${vehicle.model} (${vehicle.productionYear})',
        ),
        subtitle: Text(
          'Lokalizacja: ${vehicle.location}\n'
          'Cena: ${vehicle.dailyPrice} PLN/dzień\n'
          'Status: ${vehicle.status}\n'
          'Okres: ${_formatDateRange(startDate, endDate)}',
        ),
        isThreeLine: true,
        trailing: showCancelButton
            ? ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Anuluj'),
              )
            : null,
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final startStr = "${start.day}.${start.month}.${start.year}";
    final endStr = "${end.day}.${end.month}.${end.year}";
    return "$startStr - $endStr";
  }
}
