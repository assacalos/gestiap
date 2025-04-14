import 'package:flutter/material.dart';
import 'package:gestiap/core/services/auth_service.dart';
import 'package:gestiap/views/admin/register_screen.dart';
import 'package:gestiap/views/auth/login_screen.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildDashboardCard(
              context,
              icon: Icons.group,
              title: 'Manage Users',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterScreen(),
                  ), // Navigation vers RegisterScreen
                ); // Navigate to Manage Users screen
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.analytics,
              title: 'View Reports',
              onTap: () {
                // Navigate to View Reports screen
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                // Navigate to Settings screen
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () async {
                final authService =
                    AuthService(); // ✅ Instanciation de AuthService
                await authService.logout(); // ✅ Appel de la méthode logout()

                // ✅ Redirection vers l'écran de connexion après la déconnexion
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0, color: Theme.of(context).primaryColor),
            SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
