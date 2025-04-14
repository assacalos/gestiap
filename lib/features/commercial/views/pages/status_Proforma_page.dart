import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; // Assurez-vous que le chemin est correct // Assurez-vous que le chemin est correct
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/views/pages/proforma_form_page.dart';
import 'package:gestiap/features/commercial/views/pages/liste_Proforma_page.dart'; // Créez ces pages

class ProformaDashboardPage extends StatefulWidget {
  const ProformaDashboardPage({super.key});
  @override
  _ProformaDashboardPageState createState() => _ProformaDashboardPageState();
}

class _ProformaDashboardPageState extends State<ProformaDashboardPage> {
  // isLoading = false; // Ajout d'un indicateur de chargement
  int _currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion des Proforma')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Proforma',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DashboardButton(
                  label: 'Proforma Validés',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const ListeProformaPage(
                              status: QuoteModel.statusValidated,
                            ),
                      ),
                    );
                  },
                ),
                _DashboardButton(
                  label: 'Proforma Soumis',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const ListeProformaPage(
                              status: QuoteModel.statusPendingValidation,
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DashboardButton(
                  label: 'Proforma Rejetés',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const ListeProformaPage(
                              status:
                                  'Rejeté', // Assurez-vous que cette constante existe ou utilisez une chaîne
                            ),
                      ),
                    );
                  },
                ),
                _DashboardButton(
                  label: 'Proforma Brouillons',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const ListeProformaPage(
                              status: QuoteModel.statusDraft,
                            ),
                      ),
                    );
                  },
                ),
              ],
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
      ), // Utilisez votre BottomBar personnalisée
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DevisFormPage()),
          );
        },
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _DashboardButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
