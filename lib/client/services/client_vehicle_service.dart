import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../vehicle/models/vehicle_model.dart';

class ClientVehicleService {
  final String baseUrl;

  ClientVehicleService({required this.baseUrl});

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final token = await _getToken();
    if (token == null) throw Exception('Brak tokenu dostępu.');

    final response = await http.get(
      Uri.parse('$baseUrl/vehicles/all'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } else if (response.statusCode == 403) {
      throw Exception(
          'Brak uprawnień do pobrania listy pojazdów. Upewnij się, że jesteś zalogowany jako klient.');
    } else {
      throw Exception('Nie udało się pobrać listy pojazdów: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getClientProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) throw Exception('No access token found');

    final response = await http.get(
      Uri.parse('$baseUrl/clients/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load client profile: ${response.body}');
    }
  }

  Future<void> reserveVehicle(
      String vehicleId, DateTime startDate, DateTime endDate) async {
    final token = await _getToken();
    if (token == null) throw Exception('Brak tokenu dostępu.');

    final response = await http.post(
      Uri.parse('$baseUrl/reservations/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'vehicleId': vehicleId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'rentalPrice': 100.0, // Przykładowa cena; dostosuj według potrzeb
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Nie udało się zarezerwować pojazdu: ${response.body}');
    }
  }

  Future<List<dynamic>> getReservedVehicles() async {
    final token = await _getToken();
    if (token == null) throw Exception('Brak tokenu dostępu.');

    final response = await http.get(
      Uri.parse('$baseUrl/reservations/my'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Nie udało się pobrać rezerwacji: ${response.body}');
    }
  }


Future<void> cancelReservation(String reservationId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Brak tokenu dostępu.');

    final response = await http.post(
      Uri.parse('$baseUrl/reservations/cancel/$reservationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final responseData = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint(responseData['message']);
    } else {
      throw Exception(
          'Nie udało się anulować rezerwacji: ${responseData['message']}');
    }
  }




  Future<void> completeProfile(Map<String, dynamic> profileData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.patch(
      Uri.parse('$baseUrl/clients/complete-profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(profileData),
    );

    if (response.statusCode != 200) {
      throw Exception('Nie udało się uzupełnić profilu: ${response.body}');
    }
  }

  Future<void> updateClientProfile(Map<String, dynamic> updateData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Brak tokena autoryzacyjnego. Zaloguj się ponownie.');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/clients/update-profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      await prefs.setBool(
          'isProfileComplete', responseData['isProfileComplete']);
    } else {
      throw Exception('Nie udało się zaktualizować profilu: ${response.body}');
    }
  }
}
