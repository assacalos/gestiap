import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:gestiap/features/commercial/views/pages/bon_commande/bon_commande_list.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:gestiap/features/commercial/views/pages/clients/client_status_clients.dart';
import 'package:gestiap/features/commercial/views/pages/clients/clients_page.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:gestiap/features/commercial/views/pages/proforma/proforma_page.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:gestiap/features/commercial/views/pages/bordereaux/status_bordereau_page.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/status_Proforma_page.dart';
import 'package:gestiap/views/conf/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gestiap/core/constants/app_constants.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';
import 'package:gestiap/features/commercial/providers/bordereaux/bordereaux_provider.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux/bordereaux_form.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux/bordereaux_page.dart';
import 'package:intl/intl.dart'; // Pour la mise en forme de la monnaie et des pourcentages

class CommercialDashboardPage extends StatefulWidget {
  @override
  _CommercialDashboardPageState createState() =>
      _CommercialDashboardPageState();
}

class _CommercialDashboardPageState extends State<CommercialDashboardPage> {
  int _currentPageIndex = 0;
  Widget _currentBody = CommercialDashboardPage(); // Page d'accueil par défaut
  void _handleTabChange(int index) {
    setState(() {
      _currentPageIndex = index;
      switch (index) {
        case 0:
          _currentBody =
              CommercialDashboardPage(); // Afficher la page d'accueil
          break;
        case 1:
          // Naviguer vers l'écran des paramètres (ouvrir un nouvel écran)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          ).then((_) {
            // Lorsque l'on revient de l'écran des paramètres, réinitialiser l'index
            setState(() {
              _currentPageIndex = 0; // Retourner à l'onglet "Home" par défaut
            });
          });
          break;
        // Ajoutez d'autres cas pour d'autres onglets si nécessaire
      }
    });
  }

  // Données factices pour l'aperçu des performances - Remplacez par vos données réelles
  double _salesRevenue = 1500000.00;
  double _salesTarget = 2000000.00;
  int _newClientsCount = 50;
  int _totalClientsCount = 200;
  String _currency =
      'FCFA'; // Vous pouvez récupérer la devise de la configuration
  final DateFormat _dateFormat = DateFormat(
    'dd/MM/yyyy',
  ); // Exemple de format de date

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(
      context,
    ); // Accède au ClientProvider

    return Scaffold(
      appBar: CustomAppBar(),
      /* AppBar(
        title: Text('Tableau de Bord Commercial'),
        centerTitle: true,
      ), */
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Ajout de SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPerformanceOverview(), // Aperçu des performances
              SizedBox(height: 20),
              _buildQuickAccessGrid(), // Grille d'accès rapide
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabChange: _handleTabChange,
        initialIndex: _currentPageIndex,
      ),
    );
  }

  // Méthode pour construire l'aperçu des performances
  Widget _buildPerformanceOverview() {
    // Utilisation de NumberFormat pour formater la devise et les pourcentages
    final numberFormat = NumberFormat.currency(
      name: _currency,
      symbol: _currency,
      decimalDigits: 2,
    );
    final percentFormat = NumberFormat(
      '%',
      'fr_FR',
    ); // Correction : Utiliser le modèle '%'

    // Calcul du pourcentage d'atteinte de l'objectif
    double targetPercentage =
        _salesTarget > 0 ? _salesRevenue / _salesTarget : 0;
    String formattedTargetPercentage = percentFormat.format(targetPercentage);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.3 * 255).round()),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Aperçu des performances',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Chiffre d\'affaires : ${numberFormat.format(_salesRevenue)}',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Objectifs : $formattedTargetPercentage (${numberFormat.format(_salesTarget)})',
            style: TextStyle(
              fontSize: 16,
              color:
                  targetPercentage >= 1
                      ? Colors.green
                      : Colors
                          .orange, // Change la couleur si l'objectif est atteint ou non
            ),
          ),
          Text(
            'Nouveaux clients : $_newClientsCount',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Total clients : $_totalClientsCount',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPerformanceCard(
                context,
                "Devis en cours",
                "25",
                () {},
              ), // Exemple
              _buildPerformanceCard(
                context,
                "Commandes en attente",
                "12",
                () {},
              ), // Exemple
            ],
          ),
        ],
      ),
    );
  }

  // Widget pour construire les cartes de performance
  Widget _buildPerformanceCard(
    BuildContext context,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.2 * 255).round()),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        width:
            MediaQuery.of(context).size.width /
            2.5, // Ajuster la largeur selon le besoin
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour construire la grille d'accès rapide
  Widget _buildQuickAccessGrid() {
    return GridView.count(
      shrinkWrap:
          true, // Important pour utiliser dans une Column avec SingleChildScrollView
      physics:
          NeverScrollableScrollPhysics(), // Pour désactiver le défilement de la grille
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDashboardItem(context, 'Gestion des clients', Icons.people, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClientDashboardPage()),
          );
        }),
        _buildDashboardItem(
          context,
          'Gestion des Proforma',
          Icons.monetization_on,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProformaDashboardPage()),
            );
          },
        ),
        _buildDashboardItem(
          context,
          'Gestion des bordereaux ',
          Icons.assignment,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BordereauxDashboardPage(),
              ),
            );
          },
        ),
        _buildDashboardItem(
          context,
          'Gestion des Bons de Commande',
          Icons.inventory,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BonsDeCommandeListPage()),
            );
          },
        ),
      ],
    );
  }

  // Méthode pour construire chaque élément de la grille
  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.3 * 255).round()),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.green), // Couleur verte
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
