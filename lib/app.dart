import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'features/commercial/views/pages/commercial_dashboard_page.dart';

import 'features/comptable/views/pages/comptable_dashboard_page.dart';
import 'features/technicien/views/pages/technicien_dashboard_page.dart';
import 'views/auth/login_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: ThemeData(useMaterial3: true),
      home: Consumer<AppAuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoggedIn) {
            // Navigation basée sur le rôle
            switch (authProvider.userRole) {
              case 'commercial':
                return CommercialDashboardPage();
              case 'comptable':
                return ComptabiliteDashboardPage(); // Créez ComptableDashboardPage
              case 'technicien':
                return TechnicienDashboardPage(); // Créez TechnicienDashboardPage
              default:
                return CommercialDashboardPage(); // Rôle par défaut
            }
          } else {
            return LoginScreen(); // Redirige vers la connexion
          }
        },
      ),
    );
  }
}
