import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:carrent_frontend/screens/login_screen.dart';
import 'package:carrent_frontend/screens/register_screen.dart';
import 'package:carrent_frontend/colors.dart';
import 'package:carrent_frontend/client/screens/client_home_screen.dart';
import 'package:carrent_frontend/rental_admin/screens/navigation_menu_rental_admin.dart';
import 'package:carrent_frontend/platform_admin/screens/navigation_menu_platform_admin.dart';
import 'package:carrent_frontend/platform_admin/screens/rental_admin_list_screen.dart';
import 'package:carrent_frontend/platform_admin/services/platform_admin_service.dart';
import 'package:carrent_frontend/platform_admin/screens/platform_admin_profil_screen.dart';
import 'package:carrent_frontend/platform_admin/screens/create_rental_admin_screen.dart';
import 'package:carrent_frontend/platform_admin/screens/platform_admin_promotion_screen.dart';
import 'package:carrent_frontend/rental_company/screens/rental_company_list_screen.dart';
import 'package:carrent_frontend/rental_company/services/rental_company_service.dart';
import 'package:carrent_frontend/rental_company/screens/create_rental_company_screen.dart';
import 'package:carrent_frontend/rental_admin/services/rental_admin_service.dart';
import 'package:carrent_frontend/employee/screens/employee_list_screen.dart';
import 'package:carrent_frontend/vehicle/screens/create_vehicle_screen.dart';
import 'package:carrent_frontend/vehicle/screens/vehicle_list_screen.dart';
import 'package:carrent_frontend/vehicle/services/vehicle_service.dart';
import 'package:carrent_frontend/employee/screens/navigation_menu_employee.dart';
import 'package:carrent_frontend/employee/screens/employee_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Czyszczenie SharedPreferences
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('SharedPreferences cleared.');
  } catch (e) {
    print('Error clearing SharedPreferences: $e');
  }

  // Inicjalizacja usług
  final rentalService = RentalService(baseUrl: 'http://10.0.2.2:3000');
  final rentalCompanyService =
      RentalCompanyService(baseUrl: 'http://10.0.2.2:3000');
  final platformAdminService =
      RentalAdminService(baseUrl: 'http://10.0.2.2:3000');
  final vehicleService = VehicleService(baseUrl: 'http://10.0.2.2:3000');

  // Uruchomienie aplikacji bez zapisanego tokenu i roli
  runApp(MyApp(
    token: null,
    role: null,
    rentalCompanyId: null,
    rentalService: rentalService,
    rentalCompanyService: rentalCompanyService,
    platformAdminService: platformAdminService,
    vehicleService: vehicleService,
  ));
}

class MyApp extends StatelessWidget {
  final String? token;
  final String? role;
  final String? rentalCompanyId;
  final RentalService? rentalService;
  final RentalCompanyService? rentalCompanyService;
  final RentalAdminService? platformAdminService;
  final VehicleService? vehicleService;

  const MyApp({
    super.key,
    required this.token,
    required this.role,
    required this.rentalCompanyId,
    required this.rentalService,
    required this.rentalCompanyService,
    required this.platformAdminService,
    required this.vehicleService,
  });

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
      initialRoute: 'Login', // Zawsze rozpoczynamy od ekranu logowania
      routes: {
        'Register': (context) => const RegisterWidget(),
        'Login': (context) => LoginWidget(getHomeRoute: _getHomeRoute),

        // Routes for different roles
        'ClientHome': (context) => const ClientHomeScreen(),
        'NavigationMenuRentalAdmin': (context) => NavigationMenuRentalCompany(),
        'NavigationMenuPlatformAdmin': (context) =>
            NavigationMenuPlatformAdmin(),

        // Platform admin screens
        'RentalPlatformProfile': (context) =>
            PlatformAdminProfile(service: platformAdminService!),
        'CreateRentalAdminScreen': (context) =>
            CreateRentalAdminScreen(service: platformAdminService!),
        'PromotionsScreen': (context) => const PromotionsScreen(),
        'RentalAdminScreenView': (context) =>
            RentalAdminListScreen(service: platformAdminService!),

        // Rental company screens
        'RentalCompanyListScreen': (context) =>
            RentalCompanyListScreen(service: rentalCompanyService!),
        'CreateRentalCompany': (context) =>
            CreateRentalCompanyScreen(service: rentalCompanyService!),

        // Employee screens
        'EmployeeListScreen': (context) => EmployeeListScreen(
              service: rentalCompanyService!,
              rentalCompanyId: rentalCompanyId ?? '',
            ),

        // Vehicle screens
        'VehicleListScreen': (context) =>
            VehicleListScreen(service: vehicleService!),
        'CreateVehicleScreen': (context) => CreateVehicleScreen(
              service: vehicleService!,
              rentalCompanyId: rentalCompanyId ?? '',
            ),
        'NavigationMenuEmployee': (context) => NavigationMenuEmployee(),
        'EmployeeProfileScreen': (context) => EmployeeProfileScreen(
              service: rentalCompanyService!,
            ),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Unknown route: ${settings.name}'),
            ),
          ),
        );
      },
    );
  }

  // Determine default route based on role (nie jest już używane w tym scenariuszu)
  String _getHomeRoute(String? role) {
    print('Determining home route for role: $role');
    switch (role) {
      case 'platform_admin':
        return 'NavigationMenuPlatformAdmin';
      case 'rental_admin':
        return 'NavigationMenuRentalAdmin';
      case 'employee':
        return 'NavigationMenuEmployee';
      default:
        return 'ClientHome';
    }
  }
}
