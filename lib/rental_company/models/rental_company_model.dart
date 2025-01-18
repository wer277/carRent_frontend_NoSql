class RentalCompany {
  final String id;
  final String name;
  final String contactEmail;
  final String contactPhone;
  final String address;
  final String rentalPolicy;
  final String discountPolicy;

  RentalCompany({
    required this.id,
    required this.name,
    required this.contactEmail,
    required this.contactPhone,
    required this.address,
    required this.rentalPolicy,
    required this.discountPolicy,
  });

  factory RentalCompany.fromJson(Map<String, dynamic> json) {
    return RentalCompany(
      id: json['_id'],
      name: json['name'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'] ?? '',
      address: json['address'] ?? '',
      rentalPolicy: json['rentalPolicy'] ?? '',
      discountPolicy: json['discountPolicy'] ?? '',
    );
  }
}
