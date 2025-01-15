import 'package:carrent_frontend/rental_admin/screens/rental_admin_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import 'package:carrent_frontend/platform_admin/screens/platform_admin_home_screen.dart';

class NavigationMenuPlatformAdmin extends StatelessWidget {
  NavigationMenuPlatformAdmin({Key? key}) : super(key: key);

  final NavigationControllerPlatformAdmin controller =
      Get.put(NavigationControllerPlatformAdmin());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: controller.screens[controller.selectedIndex.value],
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
            NavigationDestination(
                icon: Icon(Iconsax.add), label: 'Dodaj admina'),
            NavigationDestination(
                icon: Icon(Iconsax.percentage_circle), label: 'Promocje'),
            NavigationDestination(icon: Icon(Iconsax.user), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class NavigationControllerPlatformAdmin extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final screens = [
    const PlatformAdminHomeScreen(), // index 0
    Container(
      color: Colors.blue,
    ),
    Container(
      color: Colors.green,
    ),
    Container(
      color: Colors.yellow,
    ), // index 3
  ];
}
