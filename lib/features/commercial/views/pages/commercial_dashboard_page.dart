import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/views/pages/clients_page.dart';
import 'package:gestiap/features/commercial/views/pages/proforma_page.dart';
import 'package:gestiap/features/commercial/views/pages/status_bordereau_page.dart';
import 'package:gestiap/features/commercial/views/pages/status_Proforma_page.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/core/constants/app_constants.dart';
import 'package:gestiap/features/commercial/views/providers/clients_provider.dart';
import 'package:gestiap/features/commercial/views/providers/bordereaux_provider.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux_form.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux_page.dart';

class CommercialDashboardPage extends StatefulWidget {
  @override
  _CommercialDashboardPageState createState() =>
      _CommercialDashboardPageState();
}

class _CommercialDashboardPageState extends State<CommercialDashboardPage> {
  // isLoading = false; // Ajout d'un indicateur de chargement
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(
      context,
    ); // Accède au ClientProvider
    /* if (clientProvider.isLoading) {
      return Scaffold(
        appBar: CustomAppBar(),
        body: Center(child: CircularProgressIndicator()), // Affiche un loader pendant le chargement
      );
    } */
    return Scaffold(
      appBar: AppBar(title: Text('Tableau de Bord Commercial')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Partie haute : Informations/Performance
            _buildPerformanceOverview(),

            SizedBox(height: 20),

            // Partie basse : Liste des boutons
            Expanded(
              child: Column(
                children: [
                  _buildDashboardItem(
                    context,
                    'Gestion des clients',
                    Icons.people,
                    () {
                      // Naviguer vers la page de gestion des clients
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ClientsPage(), // Remplace avec ta page
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 18),
                  _buildDashboardItem(
                    context,
                    'Gestion des bordereaux',
                    Icons.assignment,
                    () {
                      // Naviguer vers la page de gestion des bordereaux
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  BordereauxDashboardPage(), // Remplace avec ta page
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  _buildDashboardItem(
                    context,
                    'Gestion des Proforma',
                    Icons.monetization_on,
                    () {
                      // Naviguer vers la page de gestion des devis
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ProformaDashboardPage(), // Remplace avec ta page
                        ),
                      );
                    },
                  ),
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
          children: [
            Icon(icon, size: 48),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Partie haute : Aperçu des performances
  Widget _buildPerformanceOverview() {
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
          Text('Chiffre d\'affaires : \$1,000,000'),
          Text('Objectifs : 75% atteints'),
          // Ajoutez plus de données ici si nécessaire
        ],
      ),
    );
  }
}
