class Vehicle {
  final String id;
  final String brand;
  final String model;
  final int productionYear;
  final String location;
  final double dailyPrice;
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
      id: json['_id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      productionYear: json['productionYear'] is int
          ? json['productionYear'] as int
          : int.parse(json['productionYear'].toString()),
      location: json['location'] as String,
      dailyPrice: json['dailyPrice'] is double
          ? json['dailyPrice'] as double
          : double.parse(json['dailyPrice'].toString()),
      status: json['status'] as String,
      rentalCompanyId: json['rentalCompanyId']?.toString() ?? '',
    );
  }

}
