import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carrent_frontend/screens/login_screen.dart';
import 'package:carrent_frontend/screens/register_screen.dart';
import 'package:carrent_frontend/colors.dart';
import 'package:carrent_frontend/client/screens/client_home_screen.dart';
import 'package:carrent_frontend/employee/screens/employee_home_screen.dart';
import 'package:carrent_frontend/rental_admin/screens/rental_admin_home_screen.dart';
import 'package:carrent_frontend/platform_admin/screens/platform_admin_home_screen.dart';
import 'package:carrent_frontend/rental_admin/screens/navigation_menu_rental_admin.dart';
import 'package:carrent_frontend/platform_admin/screens/navigation_menu_platform_admin.dart';
import 'package:carrent_frontend/platform_admin/screens/rental_admin_list_screen.dart';
import 'package:carrent_frontend/platform_admin/services/rental_admin_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Odczytaj token i rolę z SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  final role = prefs.getString('user_role');

  // Utwórz instancję RentalAdminService
  final rentalAdminService = RentalAdminService(
    baseUrl: 'http://10.0.2.2:3000',
  );

  runApp(MyApp(
    token: token,
    role: role,
    service: rentalAdminService,
  ));
}

class MyApp extends StatelessWidget {
  final String? token;
  final String? role;
  final RentalAdminService service;

  const MyApp(
      {super.key,
      required this.token,
      required this.role,
      required this.service});

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
      initialRoute: token == null ? 'Login' : _getHomeRoute(role),
      routes: {
        'Register': (context) => const RegisterWidget(),
        'Login': (context) => const LoginWidget(),

        // Ścieżki do poszczególnych ról
        'ClientHome': (context) => const ClientHomeScreen(),
        'EmployeeHome': (context) => const EmployeeHomeScreen(),
        'RentalAdminHome': (context) => const RentalAdminHomeScreen(),
        'PlatformAdminHome': (context) => const PlatformAdminHomeScreen(),
        'NavigationMenuRentalAdmin': (context) => NavigationMenuRentalAdmin(),
        'NavigationMenuPlatformAdmin': (context) =>
            NavigationMenuPlatformAdmin(),
        'RentalAdminScreenView': (context) =>
            RentalAdminListScreen(service: service),
      },
    );
  }

  // Funkcja zwraca odpowiednią trasę w zależności od roli
  String _getHomeRoute(String? role) {
    switch (role) {
      case 'platform_admin':
        return 'NavigationMenuPlatformAdmin';
      case 'rental_admin':
        return 'RentalAdminHome';
      case 'employee':
        return 'EmployeeHome';
      default:
        return 'ClientHome';
    }
  }
}
