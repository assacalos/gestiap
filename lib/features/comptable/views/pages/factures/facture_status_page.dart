import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/comptable/data/models/facture_model.dart';
import 'package:gestiap/features/comptable/views/pages/factures/facture_form_page.dart';
import 'package:gestiap/features/comptable/views/pages/factures/facture_liste_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Importez le package provider

class FactureDashboardPage extends StatefulWidget {
  const FactureDashboardPage({super.key});

  @override
  _FactureDashboardPageState createState() => _FactureDashboardPageState();
}

class _FactureDashboardPageState extends State<FactureDashboardPage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestion des Factures',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tableau de Bord Factures',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.blue[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildDashboardButton(
                    context: context,
                    label: 'Factures Validées',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const FacturesPage(
                                statusFilter: InvoiceModel.statusValidated,
                              ),
                        ),
                      );
                    },
                    icon: Icons.check_circle_outline,
                    backgroundColor: Colors.green[100],
                    textColor: Colors.green[800],
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildDashboardButton(
                    context: context,
                    label: 'Factures Soumises',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const FacturesPage(
                                statusFilter: InvoiceModel.statusSubmitted,
                              ),
                        ),
                      );
                    },
                    icon: Icons.pending_actions,
                    backgroundColor: Colors.amber[100],
                    textColor: Colors.amber[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildDashboardButton(
                    context: context,
                    label: 'Factures Payées',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const FacturesPage(
                                statusFilter: InvoiceModel.statusPayee,
                              ),
                        ),
                      );
                    },
                    icon: Icons.monetization_on_outlined,
                    backgroundColor: Colors.lightGreen[100],
                    textColor: Colors.lightGreen[800],
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildDashboardButton(
                    context: context,
                    label: 'Factures Impayées',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const FacturesPage(
                                statusFilter: InvoiceModel.statusImpayee,
                              ),
                        ),
                      );
                    },
                    icon: Icons.money_off_outlined,
                    backgroundColor: Colors.orange[100],
                    textColor: Colors.orange[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildDashboardButton(
                    context: context,
                    label: 'Factures Rejetées',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const FacturesPage(
                                statusFilter: InvoiceModel.statusRejected,
                              ),
                        ),
                      );
                    },
                    icon: Icons.cancel_outlined,
                    backgroundColor: Colors.red[100],
                    textColor: Colors.red[800],
                  ),
                ),
                const SizedBox(width: 16.0),
                const Expanded(
                  child:
                      SizedBox.shrink(), // Pour aligner les boutons si nécessaire
                ),
              ],
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InvoiceFormPage()),
          );
        },
      ),
    );
  }

  Widget _buildDashboardButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: backgroundColor ?? Colors.blue,
        foregroundColor: textColor ?? Colors.white,
      ),
      icon: icon != null ? Icon(icon, size: 28) : const SizedBox.shrink(),
      label: Text(
        label,
        style: const TextStyle(fontFamily: 'Roboto'),
        textAlign: TextAlign.center,
      ),
    );
  }
}
