import 'package:flutter/material.dart';
import '../services/rental_admin_service.dart';
import '../models/rental_admin_model.dart';
import '../widgets/rental_admin_item.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_message.dart';
import 'edit_rental_admin_screen.dart';

class RentalAdminListScreen extends StatefulWidget {
  final RentalAdminService service;

  const RentalAdminListScreen({Key? key, required this.service})
      : super(key: key);

  @override
  State<RentalAdminListScreen> createState() => _RentalAdminListScreenState();
}

class _RentalAdminListScreenState extends State<RentalAdminListScreen> {
  late Future<List<RentalAdmin>> _rentalAdmins;

  @override
  void initState() {
    super.initState();
    _loadRentalAdmins();
  }

  void _loadRentalAdmins() {
    setState(() {
      _rentalAdmins = widget.service.getRentalAdmins();
    });
  }

  void _deleteRentalAdmin(String id) async {
    try {
      await widget.service.deleteRentalAdmin(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rental admin deleted successfully')),
      );
      _loadRentalAdmins();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete rental admin: $e')),
      );
    }
  }

  void _navigateToEditScreen(String rentalAdminId) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => EditRentalAdminScreen(
              rentalAdminId: rentalAdminId,
              service: widget.service,
            ),
          ),
        )
        .then((_) => _loadRentalAdmins()); // Reload list after editing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rental Admins')),
      body: FutureBuilder<List<RentalAdmin>>(
        future: _rentalAdmins,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          } else if (snapshot.hasError) {
            return ErrorMessage(
                message: 'Failed to load rental admins: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No rental admins found'));
          } else {
            final admins = snapshot.data!;
            return ListView.builder(
              itemCount: admins.length,
              itemBuilder: (context, index) {
                final admin = admins[index];
                return RentalAdminItem(
                  rentalAdmin: admin,
                  onDelete: () => _deleteRentalAdmin(admin.id),
                  onEdit: () => _navigateToEditScreen(admin.id),
                );
              },
            );
          }
        },
      ),
    );
  }
}
