import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carrent_frontend/rental_company/screens/rental_company_list_screen.dart';
import 'package:carrent_frontend/rental_company/screens/create_rental_company_screen.dart';
import 'package:carrent_frontend/rental_company/services/rental_company_service.dart';
import 'package:carrent_frontend/rental_admin/screens/rental_admin_profil_screen.dart';
import 'package:carrent_frontend/rental_admin/services/rental_admin_service.dart';

class NavigationMenuRentalCompany extends StatelessWidget {
  NavigationMenuRentalCompany({Key? key}) : super(key: key);

  final NavigationControllerRentalCompany controller =
      Get.put(NavigationControllerRentalCompany());

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
          final rentalCompanyService =
              services['rentalCompanyService'] as RentalCompanyService;
          final rentalAdminService =
              services['rentalAdminService'] as RentalService;

          return Obx(
            () => Scaffold(
              body: controller.getScreen(
                rentalCompanyService,
                rentalAdminService,
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: (index) =>
                    controller.selectedIndex.value = index,
                destinations: const [
                  NavigationDestination(
                      icon: Icon(Iconsax.home), label: 'Home'),
                  NavigationDestination(
                      icon: Icon(Iconsax.buildings), label: 'Add'),
                  NavigationDestination(
                      icon: Icon(Iconsax.add), label: 'Profile'),
                  //NavigationDestination(
                   //   icon: Icon(Iconsax.user), label: 'Profil'),
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
    if (token == null) {
      throw Exception('No access token found. Please log in.');
    }

    return {
      'rentalCompanyService':
          RentalCompanyService(baseUrl: 'http://10.0.2.2:3000'),
      'rentalAdminService': RentalService(baseUrl: 'http://10.0.2.2:3000'),
    };
  }
}

class NavigationControllerRentalCompany extends GetxController {
  final RxInt selectedIndex = 0.obs;

  Widget getScreen(RentalCompanyService rentalCompanyService,
      RentalService rentalAdminService) {
    final screens = [
      RentalCompanyListScreen(
          service: rentalCompanyService), // index 0: Placeholder for Home
      // index 1: Lista wypożyczalni
      CreateRentalCompanyScreen(
          service: rentalCompanyService), // index 2: Tworzenie wypożyczalni
      RentalAdminProfile(service: rentalAdminService),
      //RentalAdminProfile(
       //   service: rentalAdminService), // index 3: Profil rental_admin
    ];

    return screens[selectedIndex.value];
  }
}
