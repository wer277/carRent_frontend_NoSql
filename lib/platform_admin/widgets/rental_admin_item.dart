import 'package:flutter/material.dart';
import '../models/rental_admin_model.dart';

class RentalAdminItem extends StatelessWidget {
  final RentalAdmin rentalAdmin;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const RentalAdminItem({
    Key? key,
    required this.rentalAdmin,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text('${rentalAdmin.name} ${rentalAdmin.surname}'),
        subtitle: Text(rentalAdmin.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
