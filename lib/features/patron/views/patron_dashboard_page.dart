import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux_page.dart';
import 'package:gestiap/features/commercial/views/pages/clients_page.dart';
import 'package:gestiap/features/commercial/views/pages/proforma_page.dart';
import 'package:gestiap/features/commercial/views/pages/status_Proforma_page.dart';
import 'package:gestiap/features/commercial/views/providers/clients_provider.dart';
import 'package:gestiap/features/commercial/views/providers/proforma_provider.dart';
import 'package:gestiap/features/patron/views/liste_status_bordereaux_patron.dart';
import 'package:gestiap/features/patron/views/liste_status_proforma_patron.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/views/providers/bordereaux_provider.dart';

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
      appBar: AppBar(title: Text('Tableau de Bord - Patron')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Partie haute : Informations/Performance
            _buildPerformanceOverview(
              bordereauxProvider,
              clientProvider,
              quotesProvider,
            ),

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
                        MaterialPageRoute(builder: (context) => ClientsPage()),
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
                          builder: (context) => PatronBordereauxDashboardPage(),
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
                          builder: (context) => PatronProformaDashboardPage(),
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
  Widget _buildPerformanceOverview(
    BordereauxProvider bordereauxProvider,
    ClientProvider clientProvider,
    QuoteProvider quotesProvider,
  ) {
    final int totalClients = clientProvider.clients.length;
    final int totalQuotes = quotesProvider.quotes.length;
    final int totalBordereaux = bordereauxProvider.bordereaux.length;

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
          Text('Total des clients : $totalClients'),
          Text('Total des devis : $totalQuotes'),
          Text('Total des bordereaux : $totalBordereaux'),
        ],
      ),
    );
  }
}
