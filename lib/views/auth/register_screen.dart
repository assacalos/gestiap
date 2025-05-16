import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _role = "commercial"; // Rôle par défaut

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            DropdownButton<String>(
              value: _role,
              onChanged: (value) => setState(() => _role = value!),
              items:
                  [
                        'admin',
                        'commercial',
                        'comptable',
                        'technicien',
                        'rh',
                        'patron',
                      ]
                      .map(
                        (role) =>
                            DropdownMenuItem(value: role, child: Text(role)),
                      )
                      .toList(),
            ),
            ElevatedButton(
              onPressed: () async {
                bool success = await authProvider.register(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                  _role,
                );
                if (success) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AdminDashboard()),
                  );
                }
              },
              child: Text('S’inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
