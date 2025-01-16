import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rental_admin_model.dart';

class RentalAdminService {
  final String baseUrl;

  RentalAdminService({required this.baseUrl});

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<List<RentalAdmin>> getRentalAdmins() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/rental-admins/rental_admin_list'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => RentalAdmin.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch rental admins: ${response.body}');
    }
  }

  Future<void> deleteRentalAdmin(String id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/rental-admins/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete rental admin: ${response.body}');
    }
  }

  Future<void> updateRentalAdmin(String id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/rental-admins/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update rental admin: ${response.body}');
    }
  }
}
