import 'package:flutter/material.dart';
import '../models/rental_company_model.dart';

class RentalCompanyItem extends StatelessWidget {
  final RentalCompany rentalCompany;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const RentalCompanyItem({
    Key? key,
    required this.rentalCompany,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(rentalCompany.name),
        subtitle: Text(rentalCompany.contactEmail),
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
