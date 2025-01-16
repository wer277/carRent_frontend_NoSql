import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/rental_admin_model.dart';

class RentalAdminService {
  final String baseUrl;

  RentalAdminService({required this.baseUrl});

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_role');
    throw Exception('Unauthorized: Token has been cleared.');
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
    } else if (response.statusCode == 401) {
      await _handleUnauthorized(); // Obsługa błędu 401
      throw Exception('Unauthorized request.'); // Dodano `throw` dla błędu 401
    } else {
      throw Exception(
          'Failed to fetch rental admins: ${response.body}'); // Dodano `throw` dla innych błędów
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

    if (response.statusCode == 401) {
      await _handleUnauthorized(); // Obsługa błędu 401
    } else if (response.statusCode != 200) {
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

    if (response.statusCode == 401) {
      await _handleUnauthorized(); // Obsługa błędu 401
    } else if (response.statusCode != 200) {
      throw Exception('Failed to update rental admin: ${response.body}');
    }
  }

Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Usuń wszystkie dane
    await prefs.clear();

    // Przekierowanie na ekran logowania
    Navigator.pushNamedAndRemoveUntil(context, 'Login', (route) => false);
  }

}
