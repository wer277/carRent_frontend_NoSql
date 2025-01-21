import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carrent_frontend/platform_admin/screens/rental_admin_list_screen.dart';
import 'package:carrent_frontend/platform_admin/services/platform_admin_service.dart';
import 'package:carrent_frontend/platform_admin/screens/platform_admin_profil_screen.dart';
import 'package:carrent_frontend/platform_admin/screens/create_rental_admin_screen.dart';
import 'package:carrent_frontend/platform_admin/screens/platform_admin_promotion_screen.dart';

class NavigationMenuPlatformAdmin extends StatelessWidget {
  NavigationMenuPlatformAdmin({Key? key}) : super(key: key);

  final NavigationControllerPlatformAdmin controller =
      Get.put(NavigationControllerPlatformAdmin());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RentalAdminService>(
      future: _initializeService(),
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
          final service = snapshot.data!;
          return Obx(
            () => Scaffold(
              body: controller.getScreen(service),
              bottomNavigationBar: NavigationBar(
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: (index) =>
                    controller.selectedIndex.value = index,
                destinations: const [
                  NavigationDestination(
                      icon: Icon(Iconsax.home), label: 'Home'),
                  NavigationDestination(
                      icon: Icon(Iconsax.add), label: 'Dodaj admina'),
                  NavigationDestination(
                      icon: Icon(Iconsax.percentage_circle), label: 'Promocje'),
                  NavigationDestination(
                      icon: Icon(Iconsax.user), label: 'Profil'),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<RentalAdminService> _initializeService() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('No access token found. Please log in.');
    }
    return RentalAdminService(baseUrl: 'http://10.0.2.2:3000');
  }
}

class NavigationControllerPlatformAdmin extends GetxController {
  final RxInt selectedIndex = 0.obs;

  Widget getScreen(RentalAdminService service) {
    final screens = [
      RentalAdminListScreen(service: service), // index 0
      CreateRentalAdminScreen(service: service), // index 1
      PromotionsScreen(), // index 2
      PlatformAdminProfile(service: service,), // index 3
    ];

    return screens[selectedIndex.value];
  }
}
