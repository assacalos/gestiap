import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; // Assurez-vous que ce chemin est correct
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart'; // Assurez-vous que ce chemin est correct
import 'package:gestiap/features/commercial/views/pages/bordereaux/liste_bordereaux_page.dart'; // Assurez-vous que ce chemin est correct
import 'package:gestiap/features/patron/views/bordereaux/bordereaux_attente_patron.dart'; // Assurez-vous que ce chemin est correct
import 'package:gestiap/features/patron/views/bordereaux/bordereaux_rejected_patron.dart';
import 'package:gestiap/features/patron/views/bordereaux/bordereaux_validated_patron.dart';
import 'package:google_fonts/google_fonts.dart';

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
      body: Padding(
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
            _buildDashboardButton(
              context: context,
              label: 'Bordereaux en Attente',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PendingBordereauxList(),
                  ),
                );
              },
              icon: Icons.pending_actions,
              backgroundColor: Colors.amber[100],
              textColor: Colors.amber[800],
            ),
            const SizedBox(height: 20),
            _buildDashboardButton(
              context: context,
              label: 'Bordereaux Validés',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ValidatedBordereauxList(),
                  ),
                );
              },
              icon: Icons.check_circle_outline,
              backgroundColor: Colors.green[100],
              textColor: Colors.green[800],
            ),
            const SizedBox(height: 20),
            _buildDashboardButton(
              context: context,
              label: 'Bordereaux Rejetés',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RejectedBordereauxList(),
                  ),
                );
              },
              icon: Icons.cancel_outlined,
              backgroundColor: Colors.red[100],
              textColor: Colors.red[800],
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
      ),
      icon: icon != null ? Icon(icon, size: 28) : const SizedBox.shrink(),
      label: Text(label, style: const TextStyle(fontFamily: 'Roboto')),
    );
  }
}
