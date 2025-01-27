import 'package:flutter/material.dart';
import '../models/employee_model.dart';

class EmployeeItem extends StatelessWidget {
  final Employee employee;
  final VoidCallback onDelete;
  final VoidCallback onEdit; 
  final VoidCallback? onTap;

  const EmployeeItem({
    Key? key,
    required this.employee,
    required this.onDelete,
    required this.onEdit, 
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text('${employee.name} ${employee.surname}'),
        subtitle: Text(employee.email),
        onTap: onTap,
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
