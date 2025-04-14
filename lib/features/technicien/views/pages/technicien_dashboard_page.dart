import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/technicien/views/pages/stock_liste_page.dart';
import 'package:gestiap/features/technicien/views/pages/intervention_liste_page.dart';
//import 'package:gestiap/features/technicien/views/pages/planning_page.dart';
import 'package:gestiap/features/technicien/views/pages/equipment_liste_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class TechnicienDashboardPage extends StatefulWidget {
  @override
  _TechnicienDashboardPageState createState() =>
      _TechnicienDashboardPageState();
}

class _TechnicienDashboardPageState extends State<TechnicienDashboardPage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tableau de Bord Technicien')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPerformanceOverview(), // Vous pouvez créer un aperçu spécifique au technicien
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Afficher les éléments sur 2 colonnes
                childAspectRatio: 1.2, // Ajuster la hauteur des éléments
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  /* _buildDashboardItem(
                    context,
                    'Gestion des Interventions',
                    Icons.build,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => //InterventionsPage(),
                        ), // Remplacez par votre page
                      );
                    },
                  ), */
                  /*  _buildDashboardItem(
                    context,
                    'Planification',
                    Icons.calendar_today,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => //PlanningPage(),
                        ), // Remplacez par votre page
                      );
                    },
                  ), */
                  _buildDashboardItem(
                    context,
                    'Gestion des Stocks',
                    Icons.inventory,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockListPage(),
                        ),
                      );
                    },
                  ),
                  /*  _buildDashboardItem(
                    context,
                    'Gestion des Équipements',
                    Icons.devices,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => //EquipementsPage(),
                        ), // Remplacez par votre page
                      );
                    },
                  ), */

                  /*  _buildDashboardItem(
                    context,
                    'Base de Connaissances',
                    Icons.library_books,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BaseConnaissancesPage()), // Facultatif
                      );
                    },
                  ), */
                  // Ajoutez d'autres éléments ici
                ],
              ),
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
            Icon(icon, size: 40),
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
          Text('Interventions en cours : 5'),
          Text('Interventions planifiées aujourd\'hui : 3'),
          Text('Interventions résolues cette semaine : 12'),
          // Ajoutez ici des statistiques pertinentes pour les techniciens
        ],
      ),
    );
  }
}
