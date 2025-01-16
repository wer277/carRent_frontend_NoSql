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
        debugPrint("Access Token: $accessToken, Role: $role");

        // Zapisz token i rolę w SharedPreferences
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

  Future<void> _clearOldToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_role');
  }

  Future<void> _saveTokenAndRole(String? token, String? userRole) async {
    final prefs = await SharedPreferences.getInstance();

    if (token != null) {
      debugPrint("Saving token: $token");
      await prefs.setString('access_token', token);
    }

    if (userRole != null) {
      debugPrint("Saving role: $userRole");
      await prefs.setString('user_role', userRole);
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
}
