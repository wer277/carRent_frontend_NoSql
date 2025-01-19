import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginModel {
  late TextEditingController emailAddressTextController;
  late FocusNode emailAddressFocusNode;

  late TextEditingController passwordTextController;
  late FocusNode passwordFocusNode;

  bool passwordVisibility = false;

  final String _baseUrl = "http://10.0.2.2:3000/auth";

  String? accessToken;
  String? role;
  List<String>? rentalCompanyIds;

  LoginModel() {
    emailAddressTextController = TextEditingController();
    emailAddressFocusNode = FocusNode();
    passwordTextController = TextEditingController();
    passwordFocusNode = FocusNode();
  }

  void dispose() {
    emailAddressTextController.dispose();
    emailAddressFocusNode.dispose();
    passwordTextController.dispose();
    passwordFocusNode.dispose();
  }

  Future<bool> loginUser() async {
    await _clearOldToken(); // Wyczyść stare tokeny przed logowaniem

    final email = emailAddressTextController.text.trim();
    final password = passwordTextController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      debugPrint("Please fill in all fields.");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        debugPrint("Login successful: $responseData");

        accessToken = responseData["access_token"];
        role = responseData["role"];

        // Dekodowanie JWT, aby wyodrębnić rentalCompanyIds
        if (accessToken != null) {
          try {
            final parts = accessToken!.split('.');
            if (parts.length == 3) {
              final payload = parts[1];
              final normalized = base64.normalize(payload);
              final payloadMap =
                  json.decode(utf8.decode(base64.decode(normalized)));

              if (payloadMap is Map && payloadMap["rentalCompanyIds"] != null) {
                rentalCompanyIds =
                    List<String>.from(payloadMap["rentalCompanyIds"]);
              }
            } else {
              debugPrint("Invalid JWT token structure.");
            }
          } catch (e) {
            debugPrint("Error decoding JWT: $e");
          }
        }

        debugPrint("Access Token: $accessToken, Role: $role");
        debugPrint("RentalCompanyIds: $rentalCompanyIds");

        // Zapisz token, rolę i rentalCompanyIds (tylko dla employee) w SharedPreferences
        await _saveUserData(accessToken, role, rentalCompanyIds);

        return true;
      } else {
        debugPrint("Login failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error during login: $e");
      return false;
    }
  }

  Future<void> _clearOldToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Czyszczenie wszystkich zapisanych danych
  }

  Future<void> _saveUserData(
      String? token, String? userRole, List<String>? rentalCompanyIds) async {
    final prefs = await SharedPreferences.getInstance();

    if (token != null) {
      debugPrint("Saving token: $token");
      await prefs.setString('access_token', token);
    }

    if (userRole != null) {
      debugPrint("Saving role: $userRole");
      await prefs.setString('user_role', userRole);
    }

    if (userRole == "employee" &&
        rentalCompanyIds != null &&
        rentalCompanyIds.isNotEmpty) {
      debugPrint("Saving rentalCompanyIds: $rentalCompanyIds");
      await prefs.setString('rentalCompanyIds', jsonEncode(rentalCompanyIds));
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  Future<List<String>?> getRentalCompanyIds() async {
    final prefs = await SharedPreferences.getInstance();
    final rentalCompanyIdsJson = prefs.getString('rentalCompanyIds');
    if (rentalCompanyIdsJson != null) {
      return List<String>.from(json.decode(rentalCompanyIdsJson));
    }
    return null;
  }
}
