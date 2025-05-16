import 'package:flutter/material.dart';
import 'package:gestiap/features/patron/views/patron_dashboard_page.dart';
import 'package:gestiap/features/rh/views/pages/ressource_humaine_dashboard.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard.dart'; // Redirection après connexion
import 'package:gestiap/features/commercial/views/pages/commercial_dashboard_page.dart'; // Redirection après connexion
import 'package:gestiap/features/comptable/views/pages/comptable_dashboard_page.dart'; // Redirection après connexion
import 'package:gestiap/features/technicien/views/pages/technicien_dashboard_page.dart'; // Redirection après connexion

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Mot de passe'),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: () async {
                    setState(() => isLoading = true);

                    String email = _emailController.text.trim();
                    String password = _passwordController.text.trim();

                    print('Tentative de connexion avec $email');

                    // Connexion et récupération du rôle
                    String? role = await authProvider.login(email, password);
                    if (!mounted)
                      return; // Vérifie si le widget est toujours actif

                    setState(() => isLoading = false);

                    if (role != null) {
                      print('Utilisateur authentifié avec le rôle : $role');

                      // Redirection selon le rôle
                      Widget nextScreen;
                      switch (role) {
                        case "admin":
                          nextScreen = AdminDashboard();
                          break;
                        case "commercial":
                          nextScreen = CommercialDashboardPage();
                          break;
                        case "comptable":
                          nextScreen = ComptabiliteDashboardPage();
                          break;
                        case "technicien":
                          nextScreen = TechnicienDashboardPage();
                          break;
                        case "rh":
                          nextScreen =
                              RhDashboardPage(); // Remplacez par la page client appropriée
                          break;
                        case "patron":
                          nextScreen =
                              PatronDashboardPage(); // Remplacez par la page client appropriée
                          break;

                        default:
                          nextScreen = LoginScreen();
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => nextScreen),
                      );
                    } else {
                      print('Connexion échouée.');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur de connexion ou rôle inconnu'),
                        ),
                      );
                    }
                  },

                  child: Text('Se connecter'),
                ),
          ],
        ),
      ),
    );
  }
}
