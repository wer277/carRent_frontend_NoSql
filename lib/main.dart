import 'package:flutter/material.dart';
import 'package:carrent_frontend/screens/login_screen.dart';
import 'package:carrent_frontend/screens/register_screen.dart';
import 'package:carrent_frontend/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          surface: Colors.white,
          background: Colors.white,
          error: errorColor,
        ),
        useMaterial3: true,
      ),
      initialRoute: 'Register',
      routes: {
        'Register': (context) => const RegisterWidget(),
        'Login': (context) => const LoginWidget(),
      },
    );
  }
}
