// screens/employee_list_screen.dart
import 'package:flutter/material.dart';
import '../../rental_company/services/rental_company_service.dart';
import '../models/employee_model.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_message.dart';
import 'create_employee_screen.dart';
import 'edit_employee_screen.dart'; // Importuj ekran edycji
import '../widgets/employee_item.dart'; // Import EmployeeItem

class EmployeeListScreen extends StatefulWidget {
  final RentalCompanyService service;
  final String rentalCompanyId;

  const EmployeeListScreen({
    Key? key,
    required this.service,
    required this.rentalCompanyId,
  }) : super(key: key);

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late Future<List<Employee>> _employees;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  void _loadEmployees() {
    setState(() {
      _employees = widget.service.getEmployees(widget.rentalCompanyId);
    });
  }

  void _deleteEmployee(String employeeId) async {
    try {
      await widget.service.deleteEmployee(employeeId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee deleted successfully')),
      );
      _loadEmployees();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete employee: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista Pracowników',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Tło z grafiką
          Center(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/tloListView.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          // Zawartość ekranu
          FutureBuilder<List<Employee>>(
            future: _employees,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              } else if (snapshot.hasError) {
                return ErrorMessage(
                  message: 'Failed to load employees: ${snapshot.error}',
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No employees found'));
              } else {
                final employees = snapshot.data!;
                return ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return EmployeeItem(
                      employee: employee,
                      onDelete: () => _deleteEmployee(employee.id),
                      onEdit: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => EditEmployeeScreen(
                                  employee: employee,
                                  service: widget.service,
                                ),
                              ),
                            )
                            .then((_) =>
                                _loadEmployees()); // Odśwież listę po powrocie
                      },

                      onTap:
                          () {}, // Opcjonalnie: dodaj akcję onTap, jeśli potrzebna
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => CreateEmployeeScreen(
                    service: widget.service,
                    rentalCompanyId: widget.rentalCompanyId,
                  ),
                ),
              )
              .then((_) => _loadEmployees());
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
