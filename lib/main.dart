import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/providers/etat_financier_provider.dart';
import 'package:gestiap/features/comptable/providers/impot_taxe_provider.dart';
import 'package:gestiap/features/comptable/providers/paiement_provider.dart';
import 'package:gestiap/features/patron/views/rapport_intervention_patron.dart';
import 'package:gestiap/features/rh/providers/conge_provider.dart';
import 'package:gestiap/features/rh/providers/employe_provider.dart';
import 'package:gestiap/features/technicien/providers/equipements_provider.dart';
import 'package:gestiap/features/technicien/providers/interventions_provider.dart';
import 'package:gestiap/features/technicien/providers/rapport_intervention_provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/providers/auth_provider.dart';
import 'package:gestiap/core/services/auth_service.dart';
import '../views/auth/login_screen.dart';
import '../views/admin/admin_dashboard.dart';
import '../views/splash_screen.dart';
import 'package:gestiap/views/auth_check.dart'; // Importez le nouveau AuthCheck
import 'package:gestiap/views/home_screen.dart';
import 'package:gestiap/features/commercial/views/pages/commercial_dashboard_page.dart';
import 'package:gestiap/features/patron/views/patron_dashboard_page.dart';
import 'package:gestiap/features/technicien/views/pages/technicien_dashboard_page.dart';
import 'package:gestiap/features/comptable/views/pages/comptable_dashboard_page.dart';
import 'package:gestiap/features/commercial/providers/bordereaux/bordereaux_provider.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:gestiap/features/commercial/providers/bonCommandes/bon_commande_provider.dart';
import 'package:gestiap/features/comptable/providers/budget.provider.dart';
import 'package:gestiap/features/comptable/providers/charges_provider.dart';
import 'package:gestiap/features/comptable/providers/facture_provider.dart';
import 'package:gestiap/features/comptable/providers/fournisseurs_provider.dart';
import 'package:gestiap/features/technicien/providers/stock_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        AndroidProvider
            .debug, // Utilisez .debug pour les tests, changez-le en production
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppAuthProvider()),
        ChangeNotifierProvider(create: (context) => ClientProvider()),
        ChangeNotifierProvider(create: (context) => QuoteProvider()),
        // BordereauxProvider dépend maintenant des instances créées ci-dessus
        ChangeNotifierProvider(
          create:
              (context) => BordereauxProvider(
                clientProvider: Provider.of<ClientProvider>(
                  context,
                  listen: false,
                ),
                quoteProvider: Provider.of<QuoteProvider>(
                  context,
                  listen: false,
                ),
                context: context,
              ),
        ),
        ChangeNotifierProvider(create: (context) => StockProvider()),
        ChangeNotifierProvider(create: (context) => BonDeCommandeProvider()),
        ChangeNotifierProvider(create: (context) => InvoiceProvider()),
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
        ChangeNotifierProvider(create: (context) => FournisseurProvider()),
        ChangeNotifierProvider(create: (context) => ChargesProvider()),
        ChangeNotifierProvider(create: (context) => EmployeProvider()),
        ChangeNotifierProvider(create: (context) => CongeProvider()),
        ChangeNotifierProvider(create: (context) => ImpotTaxeProvider()),
        ChangeNotifierProvider(create: (context) => EtatFinancierProvider()),
        ChangeNotifierProvider(create: (context) => EquipementProvider()),
        ChangeNotifierProvider(create: (context) => InterventionProvider()),
        ChangeNotifierProvider(create: (context) => PaymentProvider()),

        ChangeNotifierProvider(
          create: (context) => RapportInterventionProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GESTAP',
        theme: ThemeData(useMaterial3: true),
        home: SplashScreen(),
      ),
    );
  }
}
