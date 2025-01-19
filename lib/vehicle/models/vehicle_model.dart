class Vehicle {
  final String id;
  final String brand;
  final String model;
  final String productionYear;
  final String location;
  final String dailyPrice;
  final String status;
  final String rentalCompanyId;

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.productionYear,
    required this.location,
    required this.dailyPrice,
    required this.status,
    required this.rentalCompanyId,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'],
      brand: json['brand'],
      model: json['model'],
      productionYear: json['productionYear'],
      location: json['location'],
      dailyPrice: json['dailyPrice'].toString(),
      status: json['status'],
      rentalCompanyId: json['rentalCompanyId'],
    );
  }
}
