class Employee {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String?
      rentalCompanyId; // Opcjonalne pole, jeśli nie zawsze jest zwracane

  Employee({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    this.rentalCompanyId,
  });

factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'] ?? '',
      name: json['name'] ?? json['firstName'] ?? 'No name provided',
      surname: json['surname'] ?? json['lastName'] ?? 'No surname provided',
      email: json['email'] ?? 'No email provided',
      rentalCompanyId: json['rentalCompanyIds'] != null &&
              (json['rentalCompanyIds'] as List).isNotEmpty
          ? json['rentalCompanyIds'][0]
          : null,
    );
  }




  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'email': email,
      'rentalCompanyId': rentalCompanyId,
    };
  }
}
