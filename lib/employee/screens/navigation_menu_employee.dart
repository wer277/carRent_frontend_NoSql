import 'dart:convert'; // Dodaj ten import
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../vehicle/screens/vehicle_list_screen.dart';
import '../../vehicle/screens/create_vehicle_screen.dart';
import '../../vehicle/services/vehicle_service.dart';
import '../../rental_company/services/rental_company_service.dart';
import 'employee_profile_screen.dart';

class NavigationMenuEmployee extends StatelessWidget {
  NavigationMenuEmployee({Key? key}) : super(key: key);

  final NavigationControllerEmployee controller =
      Get.put(NavigationControllerEmployee());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _initializeServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          final services = snapshot.data!;
          final vehicleService = services['vehicleService'] as VehicleService;
          final rentalCompanyService =
              services['rentalCompanyService'] as RentalCompanyService;
          final rentalCompanyId = services['rentalCompanyId'] as String;

          return Obx(
            () => Scaffold(
              body: controller.getScreen(
                  vehicleService, rentalCompanyService, rentalCompanyId),
              bottomNavigationBar: NavigationBar(
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: (index) =>
                    controller.selectedIndex.value = index,
                destinations: const [
                  NavigationDestination(
                      icon: Icon(Iconsax.car), label: 'My Vehicles'),
                  NavigationDestination(
                      icon: Icon(Iconsax.add), label: 'Add Vehicle'),
                  NavigationDestination(
                      icon: Icon(Iconsax.user), label: 'Profile'),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<Map<String, dynamic>> _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final rentalCompanyIdsJson = prefs.getString('rentalCompanyIds');

    if (token == null || rentalCompanyIdsJson == null) {
      throw Exception(
          'No access token or rental company IDs found. Please log in.');
    }

    List<String> rentalCompanyIds = [];
    try {
      final decoded = json.decode(rentalCompanyIdsJson);
      rentalCompanyIds = List<String>.from(decoded);
    } catch (e) {
      throw Exception('Error decoding rentalCompanyIds: $e');
    }

    if (rentalCompanyIds.isEmpty) {
      throw Exception('No rental company IDs available. Please log in.');
    }

    final rentalCompanyId = rentalCompanyIds.first;

    return {
      'vehicleService': VehicleService(baseUrl: 'http://10.0.2.2:3000'),
      'rentalCompanyService':
          RentalCompanyService(baseUrl: 'http://10.0.2.2:3000'),
      'rentalCompanyId': rentalCompanyId,
    };
  }
}

class NavigationControllerEmployee extends GetxController {
  final RxInt selectedIndex = 0.obs;

  Widget getScreen(VehicleService vehicleService,
      RentalCompanyService rentalCompanyService, String rentalCompanyId) {
    final screens = [
      VehicleListScreen(service: vehicleService), 
      CreateVehicleScreen(
          service: vehicleService,
          rentalCompanyId: rentalCompanyId), 
      EmployeeProfileScreen(
          service: rentalCompanyService), 
    ];

    return screens[selectedIndex.value];
  }
}
