import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlatformAdminProfile extends StatelessWidget {
  const PlatformAdminProfile({Key? key}) : super(key: key);

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_role');
    Navigator.pushNamedAndRemoveUntil(context, 'Login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Admin Profile'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await logout(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size(200, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Log out',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
