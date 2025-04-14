import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestiap/features/commercial/views/providers/bordereaux_provider.dart';
import 'package:gestiap/features/commercial/views/providers/proforma_provider.dart';
import 'package:gestiap/features/comptable/views/providers/budget.provider.dart';
import 'package:gestiap/features/comptable/views/providers/charges_provider.dart';
import 'package:gestiap/features/comptable/views/providers/facture_provider.dart';
import 'package:gestiap/features/comptable/views/providers/fournisseurs_provider.dart';
import 'package:gestiap/features/patron/views/patron_dashboard_page.dart';
import 'package:gestiap/features/technicien/views/pages/technicien_dashboard_page.dart';
import 'package:gestiap/features/technicien/views/providers/stock_provider.dart';
import 'package:gestiap/views/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:gestiap/features/commercial/views/pages/commercial_dashboard_page.dart';
import 'package:gestiap/features/comptable/views/pages/comptable_dashboard_page.dart';
import 'firebase_options.dart';
import 'package:gestiap/providers/auth_provider.dart';
import 'package:gestiap/core/services/auth_service.dart';
import 'views/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/admin/admin_dashboard.dart';
import 'package:gestiap/features/commercial/views/providers/clients_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ); // ⏳ Affiche un loader pendant l'initialisation
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text("Erreur : ${snapshot.error}")),
            ),
          ); // 🚨 Gère les erreurs Firebase
        }
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AppAuthProvider()),
            ChangeNotifierProvider(
              create: (context) => ClientProvider(),
            ), // Ajoute le ClientProvider ici
            ChangeNotifierProvider(
              create: (context) => QuoteProvider()..initialize(),
            ),
            ChangeNotifierProxyProvider2<
              ClientProvider,
              QuoteProvider,
              BordereauxProvider
            >(
              create:
                  (_) => BordereauxProvider(ClientProvider(), QuoteProvider()),
              update: (_, clientProvider, quoteProvider, bordereauxProvider) {
                bordereauxProvider ??= BordereauxProvider(
                  clientProvider,
                  quoteProvider,
                );
                bordereauxProvider.initialize(); // ⚠️ toujours appeler ici
                return bordereauxProvider;
              },
            ),
            ChangeNotifierProvider(
              create: (context) => StockProvider()..initialize(),
            ),
            ChangeNotifierProvider(create: (context) => InvoiceProvider()),
            ChangeNotifierProvider(create: (context) => BudgetProvider()),
            ChangeNotifierProvider(create: (context) => FournisseurProvider()),
            ChangeNotifierProvider(create: (context) => DepenseProvider()),
          ],

          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'GESTAP',
            theme: ThemeData(useMaterial3: true),
            home: TechnicienDashboardPage(), // ✅ Démarre une fois Firebase prêt
          ),
        );
      },
    );
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
  }
}
