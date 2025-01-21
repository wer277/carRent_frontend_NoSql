import '../../vehicle/models/vehicle_model.dart';

class ReservationView {
  final Vehicle vehicle;
  final DateTime startDate;
  final DateTime endDate;
  final String reservationId;

  ReservationView({
    required this.vehicle,
    required this.startDate,
    required this.endDate,
    required this.reservationId,
  });

  factory ReservationView.fromJson(Map<String, dynamic> json) {
    // Obsługa pola 'vehicleId' zamiast 'vehicle'
    Vehicle vehicle;
    if (json['vehicleId'] is Map<String, dynamic>) {
      vehicle = Vehicle.fromJson(json['vehicleId']);
    } else if (json['vehicleId'] is Vehicle) {
      vehicle = json['vehicleId'] as Vehicle;
    } else {
      throw Exception('Nieoczekiwany typ dla pola vehicleId');
    }

    return ReservationView(
      vehicle: vehicle,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      reservationId: json['_id'],
    );
  }

}
