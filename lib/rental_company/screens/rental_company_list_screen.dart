import 'package:flutter/material.dart';
import '../services/rental_company_service.dart';
import '../models/rental_company_model.dart';
import '../widgets/rental_company_item.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_message.dart';
import 'edit_rental_company_screen.dart';

class RentalCompanyListScreen extends StatefulWidget {
  final RentalCompanyService service;

  const RentalCompanyListScreen({Key? key, required this.service})
      : super(key: key);

  @override
  State<RentalCompanyListScreen> createState() =>
      _RentalCompanyListScreenState();
}

class _RentalCompanyListScreenState extends State<RentalCompanyListScreen> {
  late Future<List<RentalCompany>> _rentalCompanies;

  @override
  void initState() {
    super.initState();
    _loadRentalCompanies();
  }

  void _loadRentalCompanies() {
    setState(() {
      _rentalCompanies = widget.service.getRentalCompanies();
    });
  }

  void _deleteRentalCompany(String id) async {
    try {
      await widget.service.deleteRentalCompany(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rental company deleted successfully')),
      );
      _loadRentalCompanies();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete rental company: $e')),
      );
    }
  }

  void _navigateToEditScreen(RentalCompany rentalCompany) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => EditRentalCompanyScreen(
              rentalCompany: rentalCompany,
              service: widget.service,
            ),
          ),
        )
        .then((_) => _loadRentalCompanies()); // Reload list after editing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista Wypożyczalni',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
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
          FutureBuilder<List<RentalCompany>>(
            future: _rentalCompanies,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              } else if (snapshot.hasError) {
                return ErrorMessage(
                  message: 'Failed to load rental companies: ${snapshot.error}',
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Brak wypożyczalni'));
              } else {
                final companies = snapshot.data!;
                return ListView.builder(
                  itemCount: companies.length,
                  itemBuilder: (context, index) {
                    final company = companies[index];
                    return RentalCompanyItem(
                      rentalCompany: company,
                      onDelete: () => _deleteRentalCompany(company.id),
                      onEdit: () => _navigateToEditScreen(company),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
