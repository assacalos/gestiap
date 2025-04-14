import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/views/pages/liste_Proforma_page.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/patron/views/proforma_attente_patron.dart'; // Assurez-vous d'importer le bon modèle

class PatronProformaDashboardPage extends StatefulWidget {
  const PatronProformaDashboardPage({super.key});

  @override
  _PatronProformaDashboardPageState createState() =>
      _PatronProformaDashboardPageState();
}

class _PatronProformaDashboardPageState
    extends State<PatronProformaDashboardPage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Proformas (Patron)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gestion des Proformas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildDashboardButton(
              context: context,
              label: 'Proformas en Attente de Validation',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const PendingProformaList(), // Naviguez vers la liste dédiée
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildDashboardButton(
              context: context,
              label: 'Proformas Validés',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ListeProformaPage(
                          status: QuoteModel.statusValidated,
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
                        (context) => ListeProformaPage(
                          status: QuoteModel.statusRejected,
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
