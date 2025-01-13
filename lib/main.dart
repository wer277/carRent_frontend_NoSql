import 'package:flutter/material.dart';
import 'package:carrent_frontend/screens/login_screen.dart';
import 'package:carrent_frontend/screens/register_screen.dart';
import 'package:carrent_frontend/colors.dart';
import 'package:carrent_frontend/client/screens/client_home_screen.dart';
import 'package:carrent_frontend/employee/screens/employee_home_screen.dart';
import 'package:carrent_frontend/rental_admin/screens/rental_admin_home_screen.dart';
import 'package:carrent_frontend/platform_admin/screens/platform_admin_home_screen.dart';

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
      initialRoute: 'Login',
      routes: {
        'Register': (context) => const RegisterWidget(),
        'Login': (context) => const LoginWidget(),

        // Ścieżki do poszczególnych ról
        'ClientHome': (context) => const ClientHomeScreen(),
        'EmployeeHome': (context) => const EmployeeHomeScreen(),
        'RentalAdminHome': (context) => const RentalAdminHomeScreen(),
        'PlatformAdminHome': (context) => const PlatformAdminHomeScreen(),
      },
    );
  }
}
