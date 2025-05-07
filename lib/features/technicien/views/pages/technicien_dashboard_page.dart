import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:gestiap/features/technicien/views/pages/stocks/stock_liste_page.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:gestiap/features/technicien/views/pages/interventions/intervention_page.dart';
//import 'package:gestiap/features/technicien/views/pages/planning_page.dart';
import 'package:gestiap/features/technicien/views/pages/equipements/equipement_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart'; // Pour la mise en forme de la date

class TechnicienDashboardPage extends StatefulWidget {
  @override
  _TechnicienDashboardPageState createState() =>
      _TechnicienDashboardPageState();
}

class _TechnicienDashboardPageState extends State<TechnicienDashboardPage> {
  int _currentPageIndex = 0;
  // Données factices pour l'aperçu des interventions - Remplacez par vos données réelles
  int _interventionsEnCours = 8;
  int _interventionsPlanifieesAujourdhui = 2;
  int _interventionsResoluesCetteSemaine = 15;
  int _totalInterventions = 120;
  final DateFormat _dateFormat = DateFormat(
    'dd/MM/yyyy',
  ); // Exemple de format de date

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord Technicien'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Ajout de SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPerformanceOverview(), // Aperçu des interventions
              SizedBox(height: 20),
              _buildQuickAccessGrid(), // Grille d'accès rapide
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

  // Méthode pour construire l'aperçu des interventions
  Widget _buildPerformanceOverview() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
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
            'Aperçu des interventions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Interventions en cours : $_interventionsEnCours',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Interventions planifiées aujourd\'hui : $_interventionsPlanifieesAujourdhui',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Interventions résolues cette semaine : $_interventionsResoluesCetteSemaine',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Total interventions : $_totalInterventions',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInterventionCard(
                context,
                "Interventions urgentes",
                "3",
                () {},
              ),
              _buildInterventionCard(
                context,
                "Maintenance préventive",
                "5",
                () {},
              ), // Exemple
            ],
          ),
        ],
      ),
    );
  }

  // Widget pour construire les cartes d'intervention
  Widget _buildInterventionCard(
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
      crossAxisCount: 2, // Afficher les éléments sur 2 colonnes
      childAspectRatio: 1.2, // Ajuster la hauteur des éléments
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDashboardItem(context, 'Interventions', Icons.build, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => InterventionPage(), // Remplacez par votre page
            ),
          );
        }),
        /*_buildDashboardItem(
          context,
          'Planification',
          Icons.calendar_today,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PlanningPage(), // Remplacez par votre page
              ),
            );
          },
        ),*/
        _buildDashboardItem(context, 'Gestion des Stocks', Icons.inventory, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StockListPage()),
          );
        }),
        _buildDashboardItem(context, 'Équipements', Icons.devices, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EquipementPage(),
            ), // Remplacez par votre page
          );
        }),
        /*_buildDashboardItem(
          context,
          'Base de Connaissances',
          Icons.library_books,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BaseConnaissancesPage(), // Facultatif, Remplacez par votre page
              ),
            );
          },
        ),*/
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.orange), // Couleur orange
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
