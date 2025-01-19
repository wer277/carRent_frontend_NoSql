// models/employee_model.dart
class Employee {
  final String id;
  final String email;
  final String firstName;
  final String lastName;

  Employee({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'] as String,
      email: json['email'] as String,
      firstName: json['name'] as String,
      lastName: json['surname'] as String,
    );
  }
}
