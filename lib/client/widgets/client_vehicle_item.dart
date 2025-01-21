import 'package:flutter/material.dart';
import '../../vehicle/models/vehicle_model.dart';

class ClientVehicleItem extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onReserve;

  const ClientVehicleItem({
    Key? key,
    required this.vehicle,
    required this.onReserve,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          '${vehicle.brand} ${vehicle.model} (${vehicle.productionYear})',
        ),
        subtitle: Text(
          'Lokalizacja: ${vehicle.location}\nCena: ${vehicle.dailyPrice} PLN/dzień\nStatus: ${vehicle.status}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: onReserve,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Rezerwuj'),
            ),
          ],
        ),
      ),
    );
  }
}
