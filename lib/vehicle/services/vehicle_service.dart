import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle_model.dart';

class VehicleService {
  final String baseUrl;

  VehicleService({required this.baseUrl});

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Pobieranie wszystkich pojazdów przypisanych do wypożyczalni pracownika
  Future<List<Vehicle>> getVehicles() async {
    final token = await _getToken();
    if (token == null) throw Exception('No access token found');

    final response = await http.get(
      Uri.parse('$baseUrl/vehicles'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized request. Please log in again.');
    } else {
      throw Exception('Failed to load vehicles: ${response.body}');
    }
  }

  // Pobieranie pojazdu po ID
  Future<Vehicle> getVehicleById(String id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No access token found');

    final response = await http.get(
      Uri.parse('$baseUrl/vehicles/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Vehicle.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized request. Please log in again.');
    } else {
      throw Exception('Failed to fetch vehicle details: ${response.body}');
    }
  }

  // Tworzenie nowego pojazdu
Future<void> createVehicle(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No access token found');

    final response = await http.post(
      Uri.parse('$baseUrl/vehicles/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode != 201) {
      final errorMessage =
          json.decode(response.body)['message'] ?? 'Unknown error occurred';
      throw Exception('Failed to create vehicle: $errorMessage');
    }
  }




  // Aktualizacja danych pojazdu
Future<void> updateVehicle(String id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No access token found');

    final response = await http.patch(
      Uri.parse('$baseUrl/vehicles/update/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'brand': data['brand'],
        'model': data['model'],
        'productionYear': data['productionYear'],
        'location': data['location'],
        'dailyPrice': data['dailyPrice'],
        'status': data['status'],
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorMessage =
          json.decode(response.body)['message'] ?? 'Unknown error occurred';
      throw Exception('Failed to update vehicle: $errorMessage');
    }
  }


  // Usuwanie pojazdu
  Future<void> deleteVehicle(String id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No access token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/vehicles/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete vehicle: ${response.body}');
    }
  }
}
