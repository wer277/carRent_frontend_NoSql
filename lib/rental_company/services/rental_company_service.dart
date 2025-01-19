// services/rental_company_service.dart (rozszerzony o funkcje dla pracowników)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rental_company_model.dart';
import '../../employee/models/employee_model.dart';

class RentalCompanyService {
  final String baseUrl;

  RentalCompanyService({required this.baseUrl});

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<List<RentalCompany>> getRentalCompanies() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/rental-company/my-companies'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => RentalCompany.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized request');
    } else {
      throw Exception('Failed to fetch rental companies: ${response.body}');
    }
  }

  Future<void> createRentalCompany(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/rental-company/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode != 201) {
      final errorMessage =
          json.decode(response.body)['message'] ?? 'Unknown error';
      throw Exception('Failed to create rental company: $errorMessage');
    }
  }

  Future<void> updateRentalCompany(String id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/rental-company/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      final errorMessage =
          json.decode(response.body)['message'] ?? 'Unknown error';
      throw Exception('Failed to update rental company: $errorMessage');
    }
  }

  Future<void> deleteRentalCompany(String id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/rental-company/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204 || response.statusCode != 201) {
      final errorMessage =
          json.decode(response.body)['message'] ?? 'Unknown error';
      throw Exception('Failed to delete rental company: $errorMessage');
    }
  }

  Future<List<Employee>> getEmployees(String rentalCompanyId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/employee/employees/$rentalCompanyId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Employee.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized request');
    } else {
      throw Exception('Failed to load employees: ${response.body}');
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No access token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/employee/delete-employee/$employeeId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorMessage =
          json.decode(response.body)['message'] ?? 'Unknown error';
      throw Exception('Failed to delete employee: $errorMessage');
    }
  }


  Future<void> createEmployee(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No access token found');

    final response = await http.post(
      Uri.parse('$baseUrl/auth/create-employee'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final errorMessage = json.decode(response.body)['message'] ?? 'Unknown error';
      throw Exception('Failed to create employee: $errorMessage');
    }
  }

  Future<void> updateEmployee(String id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No access token found');

    final response = await http.patch(
      Uri.parse('$baseUrl/employee/update-employee/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorMessage =
          json.decode(response.body)['message'] ?? 'Unknown error';
      throw Exception('Failed to update employee: $errorMessage');
    }
  }

  Future<Employee> getCurrentEmployee() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/employee/current'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Employee.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized request');
    } else {
      throw Exception('Failed to fetch employee data: ${response.body}');
    }
  }
}

