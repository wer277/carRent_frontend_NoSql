import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rental_admin_model.dart';

class RentalService {
  final String baseUrl;

  RentalService({required this.baseUrl});

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    throw Exception('Unauthorized access. Please log in again.');
  }


  Future<RentalAdmin> getCurrentAdmin() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/rental-admins/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return RentalAdmin.fromJson(data);
    } else if (response.statusCode == 401) {
      await _handleUnauthorized();
    }

    throw Exception('Failed to fetch rental admin data: ${response.body}');
  }

  /// Aktualizuje dane zalogowanego rental_admin
  Future<void> updateCurrentAdmin(Map<String, dynamic> updateData) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/rental-admins/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(updateData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else if (response.statusCode == 401) {
      await _handleUnauthorized();
    }

    throw Exception('Failed to update rental admin: ${response.body}');
  }
}
