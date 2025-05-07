import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; // Assurez-vous que le chemin d'accès est correct
//import 'package:gestiap/features/rh/views/pages/employes_liste_page.dart'; // Assurez-vous que le chemin d'accès est correct
//import 'package:gestiap/features/rh/views/pages/conges_liste_page.dart'; // Assurez-vous que le chemin d'accès est correct
//import 'package:gestiap/features/rh/views/pages/formations_liste_page.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart'; // Pour la mise en forme de la date

class RhDashboardPage extends StatefulWidget {
  @override
  _RhDashboardPageState createState() => _RhDashboardPageState();
}

class _RhDashboardPageState extends State<RhDashboardPage> {
  int _currentPageIndex = 0;
  // Données factices pour l'aperçu des RH - Remplacez par vos données réelles
  int _nombreEmployes = 150;
  int _congesEnCours = 10;
  int _formationsPlanifieesCeMois = 5;
  int _nouveauxEmployesCeMois = 5;
  final DateFormat _dateFormat = DateFormat(
    'dd/MM/yyyy',
  ); // Exemple de format de date

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tableau de Bord RH'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Pour permettre le défilement
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPerformanceOverview(), // Aperçu des RH
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

  // Méthode pour construire l'aperçu des performances RH
  Widget _buildPerformanceOverview() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[100], // Couleur thème RH
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
            'Aperçu des Ressources Humaines',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Nombre total d\'employés : $_nombreEmployes',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Congés en cours : $_congesEnCours',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Formations planifiées ce mois : $_formationsPlanifieesCeMois',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Nouveaux employés ce mois : $_nouveauxEmployesCeMois',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRhCard(context, "Employés à temps partiel", "20", () {}),
              _buildRhCard(context, "Départs ce mois", "2", () {}),
            ],
          ),
        ],
      ),
    );
  }

  // Widget pour construire les cartes RH
  Widget _buildRhCard(
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
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDashboardItem(context, 'Employés', Icons.people, () {
          /*Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmployesListPage(),
              ),
            );*/
        }),
        _buildDashboardItem(context, 'Congés', Icons.date_range, () {
          /*Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CongesListPage(),
              ),
            );*/
        }),
        _buildDashboardItem(context, 'Formations', Icons.school, () {
          /*Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormationsListPage(),
              ),
            );*/
        }),
        _buildDashboardItem(context, 'Recrutement', Icons.person_add, () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => RecrutementPage()),);
        }),
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
            Icon(icon, size: 40, color: Colors.purple), // Couleur pour RH
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
