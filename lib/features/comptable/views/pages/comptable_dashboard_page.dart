import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/comptable/views/pages/fournisseurs_liste_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gestiap/features/comptable/views/pages/facture_liste_page.dart';
import 'package:gestiap/features/comptable/views/pages/charge_liste_page.dart';
import 'package:gestiap/features/comptable/views/pages/paiement_liste_page.dart';
//import 'package:gestiap/features/comptabilite/views/pages/rapprochement_bancaire_page.dart';
import 'package:gestiap/features/comptable/views/pages/impot_taxe_page.dart';
import 'package:gestiap/features/comptable/views/pages/etat_financier_page.dart';
import 'package:gestiap/features/comptable/views/pages/budget_liste_page.dart';
//import 'package:gestiap/features/comptabilite/views/pages/analyses_rapports_page.dart';
//import 'package:gestiap/features/comptabilite/views/pages/immobilisations_page.dart';

class ComptabiliteDashboardPage extends StatefulWidget {
  @override
  _ComptabiliteDashboardPageState createState() =>
      _ComptabiliteDashboardPageState();
}

class _ComptabiliteDashboardPageState extends State<ComptabiliteDashboardPage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tableau de Bord Comptabilité')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFinancialOverview(), // Aperçu financier
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
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
                        MaterialPageRoute(
                          builder: (context) => FacturesPage(),
                        ), // Remplacez par votre page de factures
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
                        MaterialPageRoute(
                          builder: (context) => DepensesPage(),
                        ), // Remplacez par votre page de dépenses
                      );
                    },
                  ),
                  /*  _buildDashboardItem(
                    context,
                    'Gestion des Paiements',
                    Icons.payments,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => //PaiementsPage(),
                        ), // Remplacez par votre page de paiements
                      );
                    },
                  ), */
                  /*  _buildDashboardItem(
                    context,
                    'Rapprochement Bancaire',
                    Icons.account_balance,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RapprochementBancairePage(),
                        ), // Remplacez par votre page
                      );
                    },
                  ), */
                  /*  _buildDashboardItem(
                    context,
                    'Impôts et Taxes',
                    Icons.attach_money,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => //ImpotsTaxesPage(),
                        ), // Remplacez par votre page
                      );
                    },
                  ), */
                  /* _buildDashboardItem(
                    context,
                    'États Financiers',
                    Icons.assessment,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => //EtatsFinanciersPage(),
                        ), // Remplacez par votre page
                      );
                    },
                  ), */
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
                  /* _buildDashboardItem(
                    context,
                    'Analyses et Rapports',
                    Icons.analytics,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnalysesRapportsPage(),
                        ), // Remplacez par votre page
                      );
                    },
                  ), */
                  /*  _buildDashboardItem(
                    context,
                    'Gestion des Immobilisations',
                    Icons.business,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImmobilisationsPage(),
                        ), // Remplacez par votre page
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

  Widget _buildFinancialOverview() {
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
          Text('Revenu total du mois : \$XX,XXX'),
          Text('Dépenses totales du mois : \$YY,YYY'),
          Text('Bénéfice net (estimation) : \$ZZ,ZZZ'),
          // Ajoutez ici des indicateurs financiers clés pertinents
        ],
      ),
    );
  }
}
