import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux_form.dart';
import 'package:gestiap/features/commercial/views/pages/liste_bordereaux_page.dart';
import 'package:gestiap/features/commercial/views/providers/bordereaux_provider.dart';

class BordereauxDashboardPage extends StatefulWidget {
  const BordereauxDashboardPage({super.key});

  @override
  _BordereauxDashboardPageState createState() =>
      _BordereauxDashboardPageState();
}

class _BordereauxDashboardPageState extends State<BordereauxDashboardPage> {
  // isLoading = false; // Ajout d'un indicateur de chargement
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion des Bordereaux')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bordereaux',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _DashboardButton(
                    label: 'Bordereaux Validés',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const ListeBordereauxPage(
                                status: BordereauModel.statusValidated,
                              ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: _DashboardButton(
                    label: 'Bordereaux Soumis',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const ListeBordereauxPage(
                                status: BordereauModel.statusPendingValidation,
                              ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _DashboardButton(
                    label: 'Bordereaux Rejetés',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const ListeBordereauxPage(
                                status: BordereauModel.statusRejected,
                              ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8.0),

                Expanded(
                  child: _DashboardButton(
                    label: 'Bordereaux Brouillons',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const ListeBordereauxPage(
                                status: BordereauModel.statusDraft,
                              ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
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
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BordereauFormPage()),
          );
        },
      ), // Utilisez votre BottomBar personnalisée
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
        padding: const EdgeInsets.all(8.0),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
