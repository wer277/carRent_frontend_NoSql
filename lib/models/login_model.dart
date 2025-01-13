import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginModel {
  late TextEditingController emailAddressTextController;
  late FocusNode emailAddressFocusNode;

  late TextEditingController passwordTextController;
  late FocusNode passwordFocusNode;

  bool passwordVisibility = false;

  final String _baseUrl = "http://10.0.2.2:3000/auth";

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
        debugPrint("Login successful: ${responseData['message']}");
        // Optionally store token or user data here
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
}
