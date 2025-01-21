import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import 'client_vehicle_list_screen.dart';
import 'client_reservation_history_screen.dart';
import 'client_profile_screen.dart';
import '../services/client_vehicle_service.dart';
import '../../vehicle/services/vehicle_service.dart';

class NavigationMenuClient extends StatelessWidget {
  final ClientVehicleService clientVehicleService;
  final VehicleService vehicleService;

  NavigationMenuClient({
    Key? key,
    required this.clientVehicleService,
    required this.vehicleService,
  }) : super(key: key);

  final NavigationControllerClient controller =
      Get.put(NavigationControllerClient());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: controller.getScreen(clientVehicleService, vehicleService),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.car), label: 'Samochody'),
            NavigationDestination(
                icon: Icon(Iconsax.clipboard_text), label: 'Historia'),
            NavigationDestination(icon: Icon(Iconsax.user), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class NavigationControllerClient extends GetxController {
  final RxInt selectedIndex = 0.obs;

  Widget getScreen(
      ClientVehicleService clientService, VehicleService vehicleService) {
    final screens = [
      ClientVehicleListScreen(service: clientService),
      ClientReservationHistoryScreen(service: clientService),
      ClientProfileScreen(service: clientService),
    ];
    return screens[selectedIndex.value];
  }
}
