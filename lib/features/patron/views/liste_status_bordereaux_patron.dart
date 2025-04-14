import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/views/pages/liste_Proforma_page.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/views/pages/liste_bordereaux_page.dart';
import 'package:gestiap/features/patron/views/bordereaux_attente_patron.dart';
import 'package:gestiap/features/patron/views/proforma_attente_patron.dart'; // Assurez-vous d'importer le bon modèle

class PatronBordereauxDashboardPage extends StatefulWidget {
  const PatronBordereauxDashboardPage({super.key});

  @override
  _PatronBordereauxDashboardPageState createState() =>
      _PatronBordereauxDashboardPageState();
}

class _PatronBordereauxDashboardPageState
    extends State<PatronBordereauxDashboardPage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Bordereaux (Patron)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gestion des Bordereaux',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildDashboardButton(
              context: context,
              label: 'Bordereaux en Attente de Validation',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const PendingBordereauxList(), // Naviguez vers la liste dédiée
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildDashboardButton(
              context: context,
              label: 'Bordereaux Validés',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ListeBordereauxPage(
                          status: BordereauModel.statusValidated,
                        ), // Si vous réutilisez ListeDevisPage
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildDashboardButton(
              context: context,
              label: 'Proformas Rejetés',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ListeBordereauxPage(
                          status: BordereauModel.statusRejected,
                        ), // Si vous réutilisez ListeDevisPage
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabChange: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        initialIndex: _currentPageIndex,
      ),
    );
  }

  Widget _buildDashboardButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16),
      ),
      child: Text(label),
    );
  }
}
