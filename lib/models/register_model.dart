import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterModel {
  late TextEditingController emailAddressTextController;
  late FocusNode emailAddressFocusNode;

  late TextEditingController passwordTextController1;
  late FocusNode passwordFocusNode1;

  late TextEditingController passwordTextController2;
  late FocusNode passwordFocusNode2;

  bool passwordVisibility1 = false;
  bool passwordVisibility2 = false;

  final String _baseUrl = "http://10.0.2.2:3000/clients/register";

  void dispose() {
    emailAddressTextController.dispose();
    emailAddressFocusNode.dispose();
    passwordTextController1.dispose();
    passwordFocusNode1.dispose();
    passwordTextController2.dispose();
    passwordFocusNode2.dispose();
  }

  Future<bool> registerUser() async {
    final email = emailAddressTextController.text.trim();
    final password1 = passwordTextController1.text.trim();
    final password2 = passwordTextController2.text.trim();

    if (email.isEmpty || password1.isEmpty || password2.isEmpty) {
      debugPrint("Please fill in all fields.");
      return false;
    }

    if (password1 != password2) {
      debugPrint("Passwords do not match.");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password1,
        }),
      );

      if (response.statusCode == 201) {
        debugPrint("Registration successful: ${response.body}");
        return true;
      } else {
        debugPrint("Registration failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error during registration: $e");
      return false;
    }
  }
}
