import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux/bordereaux_page.dart';
import 'package:gestiap/features/commercial/views/pages/clients/clients_page.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/proforma_page.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/status_Proforma_page.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:gestiap/features/patron/views/bordereaux/liste_status_bordereaux_patron.dart';
import 'package:gestiap/features/patron/views/proforma/liste_status_proforma_patron.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/providers/bordereaux/bordereaux_provider.dart';
import 'package:gestiap/features/comptable/views/pages/factures/facture_form_page.dart'; // Import pour Factures
import 'package:gestiap/features/comptable/views/pages/factures/facture_liste_page.dart'; // Import pour Employés
import 'package:gestiap/features/patron/views/intervention_page_patron.dart'; // Import pour Interventions
import 'package:gestiap/features/patron/views/employe_page_patron.dart'; // Import employes
import 'package:gestiap/features/patron/views/charge_patron.dart'; // Import pour Charges
import 'package:gestiap/features/patron/views/fournisseurs_page_patron.dart'; // Import pour Fournisseurs
import 'package:gestiap/features/patron/views/stock_page_patron.dart'; // Import pour Stocks
import 'package:gestiap/features/patron/views/equipements_patron.dart'; // Import pour Equipements
import 'package:gestiap/features/patron/views/conge_page_patron.dart'; // Import pour Congés
import 'package:gestiap/features/patron/views/rapport_intervention_patron.dart'; // Import pour Rapports
import 'package:gestiap/features/patron/views/paiement_page_patron.dart'; // Import pour Paiements
import 'package:google_fonts/google_fonts.dart';

class PatronDashboardPage extends StatefulWidget {
  const PatronDashboardPage({super.key});
  @override
  _PatronDashboardPageState createState() => _PatronDashboardPageState();
}

class _PatronDashboardPageState extends State<PatronDashboardPage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bordereauxProvider = Provider.of<BordereauxProvider>(
      context,
    ); // Accède au BordereauxProvider
    final clientProvider = Provider.of<ClientProvider>(
      context,
    ); // Accède au ClientProvider
    final quotesProvider = Provider.of<QuoteProvider>(
      context,
    ); // Accède au QuoteProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord - Patron'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Ajout de SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Partie haute : Informations/Performance
              _buildPerformanceOverview(
                bordereauxProvider,
                clientProvider,
                quotesProvider,
                context,
              ), // Passer le contexte

              const SizedBox(height: 20),

              // Partie basse : Liste des boutons
              _buildDashboardMenu(
                context,
              ), // Extraction de la liste des boutons
            ],
          ),
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

  // Refactorisation de la partie haute
  Widget _buildPerformanceOverview(
    BordereauxProvider bordereauxProvider,
    ClientProvider clientProvider,
    QuoteProvider quotesProvider,
    BuildContext context, // Ajout du BuildContext
  ) {
    final int totalClients = clientProvider.clients.length;
    final int totalQuotes = quotesProvider.quotes.length;
    final int totalBordereaux = bordereauxProvider.bordereaux.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(
              0,
              0,
              0,
              0.1,
            ), // Equivalent de Colors.grey.withAlpha
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Aperçu des performances',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('Total des clients : $totalClients'),
          Text('Total des devis : $totalQuotes'),
          Text('Total des bordereaux : $totalBordereaux'),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Exemple d'utilisation du contexte pour naviguer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientsPage(), // Exemple de page
                ),
              );
            },
            child: const Text('Voir les détails'),
          ),
        ],
      ),
    );
  }

  // Refactorisation de la liste des boutons
  Widget _buildDashboardMenu(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.0, // Rapport largeur/hauteur pour des éléments carrés
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics:
          const NeverScrollableScrollPhysics(), // Empêche le défilement interne
      children: <Widget>[
        _buildDashboardItem(context, 'Clients', Icons.people, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClientsPage()),
          );
        }),
        _buildDashboardItem(context, 'Bordereaux', Icons.assignment, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatronBordereauxDashboardPage(),
            ),
          );
        }),
        _buildDashboardItem(context, 'Proformas', Icons.monetization_on, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatronProformaDashboardPage(),
            ),
          );
        }),
        _buildDashboardItem(
          context,
          'Factures',
          Icons.attach_money, // Icône appropriée
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        FacturesPage(), // Assurez-vous que cette page existe
              ),
            );
          },
        ),
        _buildDashboardItem(
          context,
          'Paiements',
          Icons.credit_card, // Icône appropriée
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        PaiementPage(), // Assurez-vous que cette page existe
              ),
            );
          },
        ),
        _buildDashboardItem(
          context,
          'Charges',
          Icons.trending_down, // Icône appropriée
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        ChargePage(), // Assurez-vous que cette page existe
              ),
            );
          },
        ),
        _buildDashboardItem(
          context,
          'Fournisseurs',
          Icons.handshake, // Icône technique
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        FournisseurPage(), // Assurez-vous que cette page existe
              ),
            );
          },
        ),
        _buildDashboardItem(
          context,
          'Stocks',
          Icons.warehouse, // Icône technique
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        StockPage(), // Assurez-vous que cette page existe
              ),
            );
          },
        ),
        _buildDashboardItem(
          context,
          'Equipements',
          Icons.build, // Icône technique
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        EquipementPage(), // Assurez-vous que cette page existe
              ),
            );
          },
        ),
        _buildDashboardItem(
          context,
          'Interventions',
          Icons.build_circle, // Icône technique
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        InterventionsPage(), // Assurez-vous que cette page existe
              ),
            );
          },
        ),
        /* _buildDashboardItem(
          context,
          'Rapports',
          Icons.pie_chart, // Icône pour les rapports
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        RapportInterventionPage(), // Assurez-vous que cette page existe
              ),
            );
          },
        ), */
        _buildDashboardItem(
          context,
          'Employés',
          Icons.badge, // Icône pour les employés
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        EmployesPage(), // Assurez-vous que cette page existe
              ),
            );
          },
        ),

        _buildDashboardItem(
          context,
          'Congés',
          Icons.calendar_today, // Icône pour les congés
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        CongesPage(), // Assurez-vous que cette page existe
              ),
            );
          },
        ),
        _buildDashboardItem(context, 'Paramètres', Icons.settings, () {
          // Implémenter la navigation vers la page des paramètres
        }),
      ],
    );
  }

  // Refactorisation du bouton
  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1), // Couleur de l'ombre
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centrer le contenu
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /* voici mon interface patron qui veut avoir une vue sur toutes activites afin de valider ce qu il doit valider au niveau des activites du commercial, du comptable, des technicien et du ressource humaine tu connais en generale la bonne interface pour ce genre d application implmente pour moi une parfaite et belle interface stp avec tous les boutons des differents activites */
}
