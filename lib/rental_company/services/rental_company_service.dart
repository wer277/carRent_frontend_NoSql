import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rental_company_model.dart';

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

    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorMessage =
          json.decode(response.body)['message'] ?? 'Unknown error';
      throw Exception('Failed to delete rental company: $errorMessage');
    }
  }

}
