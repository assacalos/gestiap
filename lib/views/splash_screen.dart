import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/providers/auth_provider.dart' as local_auth;
import 'auth/login_screen.dart';
import '../features/commercial/views/pages/commercial_dashboard_page.dart';
import '../features/comptable/views/pages/comptable_dashboard_page.dart';
import '../features/technicien/views/pages/technicien_dashboard_page.dart';
import 'admin/admin_dashboard.dart';

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => checkUser());
  }

  Future<void> checkUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // 🔴 Pas connecté → Aller à l’écran de connexion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return;
      }

      // 🔵 Connecté → Vérifier le rôle dans Firestore
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!doc.exists || !doc.data().toString().contains('role')) {
        print('Erreur : Utilisateur introuvable ou rôle non défini.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return;
      }

      String role = doc['role'];
      Widget nextScreen = getDashboardForRole(role);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    } catch (e) {
      print("Erreur lors de la récupération de l'utilisateur : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion. Réessayez.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Widget getDashboardForRole(String role) {
    switch (role) {
      case 'admin':
        return AdminDashboard();
      case 'commercial':
        return CommercialDashboardPage();
      case 'comptable':
        return ComptabiliteDashboardPage();
      case 'technicien':
        return TechnicienDashboardPage();
      default:
        return LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}
