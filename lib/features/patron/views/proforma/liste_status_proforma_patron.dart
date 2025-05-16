import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; // Assurez-vous que ce chemin est correct
import 'package:gestiap/features/commercial/views/pages/proforma/liste_Proforma_page.dart'; // Assurez-vous que ce chemin est correct
import 'package:gestiap/features/commercial/data/models/proforma_model.dart'; // Assurez-vous que ce chemin est correct
import 'package:gestiap/features/patron/views/proforma/proforma_attente_patron.dart'; // Assurez-vous que ce chemin est correct
import 'package:gestiap/features/patron/views/proforma/proforma_rejected_patron.dart';
import 'package:gestiap/features/patron/views/proforma/proforma_validated_patron.dart';
import 'package:google_fonts/google_fonts.dart'; // Importez le package google_fonts

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
      appBar: AppBar(
        title: const Text(
          'Gestion des Proformas',
          style: TextStyle(fontWeight: FontWeight.w600),
        ), // Titre plus marqué
        centerTitle: true, // Centre le titre
        elevation: 0, // Supprime l'ombre par défaut de l'AppBar
        backgroundColor: Colors.blue, // Ajoute une couleur d'arrière-plan
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white, // Couleur du texte du titre
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Augmente le padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tableau de Bord Proformas', // Titre plus descriptif
              style: TextStyle(
                fontSize: 24, // Augmente la taille de la police
                fontWeight: FontWeight.bold, // Met en gras
                fontFamily: 'Poppins',
                color: Colors.blue[800], // Couleur personnalisée
              ),
              textAlign: TextAlign.center, // Centre le titre
            ),
            const SizedBox(height: 30), // Augmente l'espacement
            _buildDashboardButton(
              context: context,
              label: 'Proformas en Attente',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const PendingQuotesList(), // Utilisez le widget correct
                  ),
                );
              },
              icon: Icons.pending_actions, // Ajoute une icône
              backgroundColor: Colors.amber[100],
              textColor: Colors.amber[800],
            ),
            const SizedBox(height: 20), // Augmente l'espacement
            _buildDashboardButton(
              context: context,
              label: 'Proformas Validées',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProformaValideePatron(),
                  ),
                );
              },
              icon: Icons.check_circle_outline, // Ajoute une icône
              backgroundColor: Colors.green[100],
              textColor: Colors.green[800],
            ),
            const SizedBox(height: 20), // Augmente l'espacement
            _buildDashboardButton(
              context: context,
              label: 'Proformas Rejetées',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RejectedProformasList(),
                  ),
                );
              },
              icon: Icons.cancel_outlined, // Ajoute une icône
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
    IconData? icon, // Ajoute un paramètre pour l'icône
    Color? backgroundColor, // Ajoute un paramètre pour la couleur de fond
    Color? textColor,
  }) {
    return ElevatedButton.icon(
      // Utilise ElevatedButton.icon
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18), // Ajuste le padding
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ), // Augmente la taille et l'épaisseur de la police
        elevation: 8, // Ajoute de l'ombre
        shape: RoundedRectangleBorder(
          // Arrondit les bords
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor:
            backgroundColor ??
            Colors
                .blue, // Utilise la couleur de fond par défaut si non spécifiée
        foregroundColor:
            textColor ?? Colors.white, // Couleur du texte et de l'icône
      ),
      icon:
          icon != null
              ? Icon(icon, size: 28)
              : const SizedBox.shrink(), // Ajoute l'icône si elle est fournie

      label: Text(
        label,
        style: const TextStyle(fontFamily: 'Roboto'),
      ), // Le texte du bouton
    );
  }
}
