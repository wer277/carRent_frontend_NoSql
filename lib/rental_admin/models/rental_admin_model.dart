class RentalAdmin {
  final String id;
  final String name;
  final String surname;
  final String email;

  RentalAdmin({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
  });

  factory RentalAdmin.fromJson(Map<String, dynamic> json) {
    return RentalAdmin(
      id: json['_id'], // Jeśli backend używa MongoDB, ID może być `_id`
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
    );
  }
}
