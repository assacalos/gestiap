import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:gestiap/features/comptable/views/pages/etats_financiers/etats_financiers_form.dart';
import 'package:gestiap/features/comptable/views/pages/fournisseurs/fournisseurs_liste_page.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:gestiap/features/comptable/views/pages/factures/facture_liste_page.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:gestiap/features/comptable/views/pages/charges/charge_liste_page.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:gestiap/features/comptable/views/pages/paiements/paiement_liste_page.dart';
//import 'package:gestiap/features/comptabilite/views/pages/rapprochement_bancaire_page.dart';
import 'package:gestiap/features/comptable/views/pages/impot_taxe_page.dart';
import 'package:gestiap/features/comptable/views/pages/etat_financier_page.dart';
import 'package:gestiap/features/comptable/views/pages/budget_liste_page.dart';
//import 'package:gestiap/features/comptabilite/views/pages/analyses_rapports_page.dart';
//import 'package:gestiap/features/comptabilite/views/pages/immobilisations_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart'; // Pour la mise en forme de la monnaie et des dates

class ComptabiliteDashboardPage extends StatefulWidget {
  @override
  _ComptabiliteDashboardPageState createState() =>
      _ComptabiliteDashboardPageState();
}

class _ComptabiliteDashboardPageState extends State<ComptabiliteDashboardPage> {
  int _currentPageIndex = 0;
  // Données factices pour l'aperçu financier - Remplacez par vos données réelles
  double _totalRevenue = 50000.00;
  double _totalExpenses = 30000.00;
  double _netProfit = 20000.00;
  String _currency =
      'FCFA'; // Vous pouvez récupérer la devise de la configuration de l'application
  final DateFormat _dateFormat = DateFormat(
    'dd/MM/yyyy',
  ); // Exemple de format de date

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord Comptabilité'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Ajout de SingleChildScrollView pour éviter les problèmes de dépassement
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFinancialOverview(), // Aperçu financier
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

  // Méthode pour construire l'aperçu financier
  Widget _buildFinancialOverview() {
    // Utilisation de NumberFormat pour formater la devise
    final numberFormat = NumberFormat.currency(
      name: _currency,
      symbol: _currency,
      decimalDigits: 2,
    );

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[100],
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
            'Aperçu Financier',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Revenu total du mois : ${numberFormat.format(_totalRevenue)}',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Dépenses totales du mois : ${numberFormat.format(_totalExpenses)}',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Bénéfice net (estimation) : ${numberFormat.format(_netProfit)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _netProfit >= 0 ? Colors.green : Colors.red,
            ),
          ),
          // Ajoutez ici des indicateurs financiers clés pertinents
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFinancialSummaryCard(
                context,
                "Factures impayées",
                "10",
                () {},
              ),
              _buildFinancialSummaryCard(
                context,
                "Paiements en attente",
                "5",
                () {},
              ), // Exemple
            ],
          ),
        ],
      ),
    );
  }

  // Widget pour construire les cartes récapitulatives financières
  Widget _buildFinancialSummaryCard(
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
        _buildDashboardItem(
          context,
          'Gestion des Factures',
          Icons.receipt_long,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FacturesPage()),
            );
          },
        ),
        _buildDashboardItem(
          context,
          'Gestion des Charges',
          Icons.money_off,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DepensesPage()),
            );
          },
        ),
        /*_buildDashboardItem(
          context,
          'Gestion des Paiements',
          Icons.payments,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PaiementsPage(), // Remplacez par votre page de paiements
              ),
            );
          },
        ),*/
        /*_buildDashboardItem(
          context,
          'Rapprochement Bancaire',
          Icons.account_balance,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RapprochementBancairePage(), // Remplacez par votre page
              ),
            );
          },
        ),*/
        _buildDashboardItem(context, 'Impôts et Taxes', Icons.attach_money, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImpotTaxePage(), // Remplacez par votre page
            ),
          );
        }),
        _buildDashboardItem(context, 'États Financiers', Icons.assessment, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EtatFinancierPage(), // Remplacez par votre page
            ),
          );
        }),
        _buildDashboardItem(context, 'Budgets', Icons.show_chart, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BudgetsPage(),
            ), // Remplacez par votre page
          );
        }),
        _buildDashboardItem(
          context,
          'Gestion des Fournisseurs',
          Icons.local_shipping,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FournisseursPage(),
              ), // Remplacez par votre page
            );
          },
        ),
        // Choisissez une icône appropriée()
        /*_buildDashboardItem(
          context,
          'Analyses et Rapports',
          Icons.analytics,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AnalysesRapportsPage(), // Remplacez par votre page
              ),
            );
          },
        ),*/
        /*_buildDashboardItem(
          context,
          'Gestion des Immobilisations',
          Icons.business,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ImmobilisationsPage(), // Remplacez par votre page
              ),
            );
          },
        ),*/
        // Ajoutez d'autres éléments ici
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
            Icon(
              icon,
              size: 40,
              color: Colors.blue,
            ), // Couleur bleue pour l'icône
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
