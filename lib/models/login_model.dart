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

  // Dodane pola
  String? accessToken;
  String? role;

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        debugPrint("Login successful: $responseData");

        // Odczytaj pole "role" i "access_token" zwrócone przez backend
        accessToken = responseData["access_token"];
        role = responseData["role"];

        // Zapisz token i rolę w pamięci lokalnej
        await _saveTokenAndRole(accessToken, role);

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

  // Zapisanie tokenu i roli w pamięci lokalnej
  Future<void> _saveTokenAndRole(String? token, String? userRole) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('access_token', token);
    }
    if (userRole != null) {
      await prefs.setString('user_role', userRole);
    }
  }

  // Pobranie tokenu z pamięci lokalnej
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Pobranie roli z pamięci lokalnej
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }
}
