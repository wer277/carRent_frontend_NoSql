import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import 'package:carrent_frontend/client/screens/client_home_screen.dart';

class NavigationMenu extends StatelessWidget {
  NavigationMenu({Key? key}) : super(key: key);

  final NavigationController controller = Get.put(NavigationController());

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

class NavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final screens = [
    const ClientHomeScreen(), // index 0
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
