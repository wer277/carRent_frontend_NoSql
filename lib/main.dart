import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Czyszczenie SharedPreferences przed uruchomieniem aplikacji
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('SharedPreferences cleared.');
  } catch (e) {
    print('Error clearing SharedPreferences: $e');
  }

  // Inicjalizacja usług
  final rentalCompanyService =
      RentalCompanyService(baseUrl: 'http://10.0.2.2:3000');
  final platformAdminService =
      RentalAdminService(baseUrl: 'http://10.0.2.2:3000');
  final vehicleService = VehicleService(baseUrl: 'http://10.0.2.2:3000');

  runApp(MyApp(
    rentalCompanyService: rentalCompanyService,
    platformAdminService: platformAdminService,
    vehicleService: vehicleService,
  ));
}

class MyApp extends StatefulWidget {
  final RentalCompanyService rentalCompanyService;
  final RentalAdminService platformAdminService;
  final VehicleService vehicleService;

  const MyApp({
    super.key,
    required this.rentalCompanyService,
    required this.platformAdminService,
    required this.vehicleService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? token;
  String? role;
  String? rentalCompanyId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('access_token');
      role = prefs.getString('role');
      final rentalCompanyIdsJson = prefs.getString('rentalCompanyIds');
      if (rentalCompanyIdsJson != null) {
        try {
          final decoded = json.decode(rentalCompanyIdsJson);
          rentalCompanyId = (decoded as List<dynamic>).isNotEmpty
              ? decoded.first.toString()
              : null;
        } catch (e) {
          print('Error decoding rentalCompanyIds: $e');
        }
      }
    });
  }

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
        'Login': (context) => LoginWidget(getHomeRoute: _getHomeRoute),

        // Routes based on roles
        'ClientHome': (context) => const ClientHomeScreen(),
        'NavigationMenuRentalAdmin': (context) => NavigationMenuRentalCompany(),
        'NavigationMenuPlatformAdmin': (context) =>
            NavigationMenuPlatformAdmin(),

        // Platform admin screens
        'RentalPlatformProfile': (context) =>
            PlatformAdminProfile(service: widget.platformAdminService),
        'CreateRentalAdminScreen': (context) =>
            CreateRentalAdminScreen(service: widget.platformAdminService),
        'PromotionsScreen': (context) => const PromotionsScreen(),
        'RentalAdminScreenView': (context) =>
            RentalAdminListScreen(service: widget.platformAdminService),

        // Rental company screens
        'RentalCompanyListScreen': (context) =>
            RentalCompanyListScreen(service: widget.rentalCompanyService),
        'CreateRentalCompany': (context) =>
            CreateRentalCompanyScreen(service: widget.rentalCompanyService),

        // Employee screens
        'EmployeeListScreen': (context) => EmployeeListScreen(
              service: widget.rentalCompanyService,
              rentalCompanyId: rentalCompanyId ?? '',
            ),

        // Vehicle screens
        'VehicleListScreen': (context) =>
            VehicleListScreen(service: widget.vehicleService),
        'CreateVehicleScreen': (context) => CreateVehicleScreen(
              service: widget.vehicleService,
              rentalCompanyId: rentalCompanyId ?? '',
            ),
        'NavigationMenuEmployee': (context) => NavigationMenuEmployee(),
        'EmployeeProfileScreen': (context) =>
            EmployeeProfileScreen(service: widget.rentalCompanyService),
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
