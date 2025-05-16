import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux/bordereaux_form.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux/liste_bordereaux_page.dart';
import 'package:gestiap/features/commercial/providers/bordereaux/bordereaux_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class BordereauxDashboardPage extends StatefulWidget {
  const BordereauxDashboardPage({super.key});

  @override
  _BordereauxDashboardPageState createState() =>
      _BordereauxDashboardPageState();
}

class _BordereauxDashboardPageState extends State<BordereauxDashboardPage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestion des Bordereaux',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tableau de Bord Bordereaux',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.blue[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Utilisez une Column au lieu de Row pour un affichage vertical
            Column(
              children: [
                _buildDashboardButton(
                  context: context,
                  label: 'Validés',
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
                  icon: Icons.check_circle_outline,
                  backgroundColor: Colors.green[100],
                  textColor: Colors.green[800],
                ),
                const SizedBox(height: 16.0), // Espacement entre les boutons
                _buildDashboardButton(
                  context: context,
                  label: 'Soumis',
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
                  icon: Icons.pending_actions,
                  backgroundColor: Colors.amber[100],
                  textColor: Colors.amber[800],
                ),
                const SizedBox(height: 16.0), // Espacement entre les boutons
                _buildDashboardButton(
                  context: context,
                  label: 'Rejetés',
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
                  icon: Icons.cancel_outlined,
                  backgroundColor: Colors.red[100],
                  textColor: Colors.red[800],
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
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BordereauFormPage(bordereauToEdit: null),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: backgroundColor ?? Colors.blue,
        foregroundColor: textColor ?? Colors.white,
        // Vous pouvez ajuster la largeur ici si nécessaire.
        minimumSize: const Size(
          double.infinity,
          0,
        ), // La largeur s'étend максима
      ),
      icon: icon != null ? Icon(icon, size: 28) : const SizedBox.shrink(),
      label: Text(
        label,
        style: const TextStyle(fontFamily: 'Roboto'),
        textAlign: TextAlign.center,
      ),
    );
  }
}
