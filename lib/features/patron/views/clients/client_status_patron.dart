import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; // Assurez-vous que ce chemin est correct
import 'package:gestiap/features/patron/views/clients/client_rejected_list_patron.dart';
import 'package:gestiap/features/patron/views/clients/client_validate_list.dart';
import 'package:gestiap/features/patron/views/clients/clients_pending_list_patron.dart';
import 'package:gestiap/features/patron/views/proforma/proforma_attente_patron.dart'; // Assurez-vous que ce chemin est correct
import 'package:gestiap/features/patron/views/proforma/proforma_rejected_patron.dart';
import 'package:gestiap/features/patron/views/proforma/proforma_validated_patron.dart';
import 'package:google_fonts/google_fonts.dart'; // Importez le package google_fonts

class ClientProformaDashboardPage extends StatefulWidget {
  const ClientProformaDashboardPage({super.key});

  @override
  _ClientProformaDashboardPageState createState() =>
      _ClientProformaDashboardPageState();
}

class _ClientProformaDashboardPageState
    extends State<ClientProformaDashboardPage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vos Proformas', // Titre simplifié
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
              'Status des clients', // Titre simplifié
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
              label: 'Clients en Attente', // Label adapté
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const ClientPendingList(), // Utilisez le widget ClientPendingProformaList
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
              label: 'Clients Validées', // Label adapté
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const ClientsValide(), // Utilisez le widget ClientProformaValidee
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
              label: 'Clients Rejetées', // Label adapté
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const ClientRejete(), // Utilisez le widget ClientProformaRejete
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
