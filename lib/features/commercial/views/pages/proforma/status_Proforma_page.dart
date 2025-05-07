import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/liste_proforma_page.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/proforma_form_page.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:gestiap/providers/auth_provider.dart'; // Importez votre AuthProvider

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
          appBar: AppBar(title: const Text('Gestion des Proforma')),
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
                        _navigateToProformaList(
                          context,
                          QuoteModel.statusValidated,
                          quoteProvider,
                        );
                      },
                    ),
                    _DashboardButton(
                      label: 'Proforma Soumis',
                      onPressed: () {
                        _navigateToProformaList(
                          context,
                          QuoteModel.statusPendingValidation,
                          quoteProvider,
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
                        _navigateToProformaList(
                          context,
                          QuoteModel.statusRejected,
                          quoteProvider,
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
      //  Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login
    }
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
