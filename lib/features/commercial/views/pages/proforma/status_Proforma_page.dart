import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/liste_proforma_page.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/proforma_form_page.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:gestiap/providers/auth_provider.dart'; // Assurez-vous que ce chemin est correct
import 'package:google_fonts/google_fonts.dart'; // Importez le package google_fonts

class ProformaDashboardPage extends StatefulWidget {
  const ProformaDashboardPage({super.key});
  @override
  _ProformaDashboardPageState createState() => _ProformaDashboardPageState();
}

class _ProformaDashboardPageState extends State<ProformaDashboardPage> {
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Charger les devis au démarrage de la page.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(
        context,
        listen: false,
      ); // Récupérez l'AuthProvider
      if (authProvider.user != null) {
        // Vérifiez si l'utilisateur est connecté
        Provider.of<QuoteProvider>(
          context,
          listen: false,
        ).loadQuotes(); // Charger les devis
      } else {
        // Gérez le cas où l'utilisateur n'est pas connecté
        // Affichez un message à l'utilisateur, redirigez-le vers la page de connexion, etc.
        print(
          "Utilisateur non connecté au démarrage de la page ProformaDashboardPage",
        ); // Pour débogage
        // Vous pouvez afficher un SnackBar ou naviguer vers la page de connexion ici.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez vous connecter pour accéder à cette page.'),
            duration: Duration(seconds: 5),
          ),
        );
        // Exemple de navigation vers la page de connexion (assurez-vous d'ajuster cela à votre application)
        // Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuoteProvider>(
      builder: (context, quoteProvider, child) {
        if (quoteProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (quoteProvider.errorMessage != null) {
          return Scaffold(
            body: Center(child: Text("Error: ${quoteProvider.errorMessage}")),
            // Vous pouvez ajouter un bouton pour réessayer de charger les données.
          );
        }

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
          body: SingleChildScrollView(
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
                  label: 'Proformas Validés',
                  onPressed: () {
                    _navigateToProformaList(
                      context,
                      QuoteModel.statusValidated,
                      quoteProvider,
                    );
                  },
                  icon: Icons.check_circle_outline, // Ajoute une icône
                  backgroundColor: Colors.green[100],
                  textColor: Colors.green[800],
                ),
                const SizedBox(height: 20), // Augmente l'espacement
                _buildDashboardButton(
                  context: context,
                  label: 'Proformas Soumis',
                  onPressed: () {
                    _navigateToProformaList(
                      context,
                      QuoteModel.statusPendingValidation,
                      quoteProvider,
                    );
                  },
                  icon: Icons.pending_actions, // Ajoute une icône
                  backgroundColor: Colors.amber[100],
                  textColor: Colors.amber[800],
                ),
                const SizedBox(height: 20), // Augmente l'espacement
                _buildDashboardButton(
                  context: context,
                  label: 'Proformas Rejetés',
                  onPressed: () {
                    _navigateToProformaList(
                      context,
                      QuoteModel.statusRejected,
                      quoteProvider,
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
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DevisFormPage()),
              );
            },
          ),
        );
      },
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

  void _navigateToProformaList(
    BuildContext context,
    String status,
    QuoteProvider quoteProvider,
  ) {
    final authProvider = Provider.of<AppAuthProvider>(
      context,
      listen: false,
    ); // Get AuthProvider

    if (authProvider.user != null) {
      // Check if user is logged in
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ListeProformaPage(
                key: UniqueKey(),
                status: status,
                devis:
                    quoteProvider.quotes
                        .where((quote) => quote.status == status)
                        .toList(),
              ),
        ),
      );
    } else {
      // Handle the case where the user is not logged in
      print(
        "Utilisateur non connecté avant de naviguer vers la liste Proforma",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez vous connecter pour accéder à la liste des proforma.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      //  Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login
    }
  }
}
