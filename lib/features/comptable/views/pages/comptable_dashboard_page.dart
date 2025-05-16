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
import 'package:google_fonts/google_fonts.dart'; // Importez le package google_fonts

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
        title: const Text(
          'Tableau de Bord Comptabilité',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Augmentation du padding
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tableau de Bord Comptable',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.blue[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildFinancialOverview(), // Aperçu financier stylisé
              const SizedBox(height: 20),
              _buildQuickAccessGrid(), // Grille d'accès rapide stylisée
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

  // Méthode pour construire l'aperçu financier stylisé
  Widget _buildFinancialOverview() {
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Revenu total du mois : ${numberFormat.format(_totalRevenue)}',
            style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
          ),
          Text(
            'Dépenses totales du mois : ${numberFormat.format(_totalExpenses)}',
            style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
          ),
          Text(
            'Bénéfice net (estimation) : ${numberFormat.format(_netProfit)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              color: _netProfit >= 0 ? Colors.green : Colors.red,
            ),
          ),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget pour construire les cartes récapitulatives financières stylisées
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
        width: MediaQuery.of(context).size.width / 2.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour construire la grille d'accès rapide stylisée
  Widget _buildQuickAccessGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDashboardItem(
          context,
          'Gestion des Factures',
          Icons.receipt_long,
          Colors.blue, // Couleur bleue pour les factures
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
          Colors.redAccent, // Couleur rouge pour les charges/dépenses
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DepensesPage()),
            );
          },
        ),
        _buildDashboardItem(
          context,
          'Gestion des Paiements',
          Icons.payments,
          Colors.green, // Couleur verte pour les paiements
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentListScreen(employeId: ''),
              ),
            );
          },
        ),
        _buildDashboardItem(
          context,
          'Impôts et Taxes',
          Icons.attach_money,
          Colors.orange, // Couleur orange pour les impôts
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ImpotTaxePage()),
            );
          },
        ),
        _buildDashboardItem(
          context,
          'États Financiers',
          Icons.assessment,
          Colors.purple, // Couleur violette pour les états financiers
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EtatFinancierPage()),
            );
          },
        ),
        _buildDashboardItem(
          context,
          'Budgets',
          Icons.show_chart,
          Colors.teal, // Couleur teal pour les budgets
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BudgetsPage()),
            );
          },
        ),
        _buildDashboardItem(
          context,
          'Gestion des Fournisseurs',
          Icons.local_shipping,
          Colors.indigo, // Couleur indigo pour les fournisseurs
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FournisseursPage()),
            );
          },
        ),
        // Vous pouvez ajouter d'autres éléments ici
      ],
    );
  }

  // Méthode pour construire chaque élément de la grille stylisée
  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor, // Ajout de la couleur de l'icône
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
              color: iconColor, // Utilisation de la couleur passée en paramètre
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
