import 'package:flutter/material.dart';
import 'package:gestiap/core/services/auth_service.dart';
import 'package:gestiap/core/services/email_service.dart';
import 'package:gestiap/views/admin/register_screen.dart';
import 'dart:math';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final AuthService _authService = AuthService();

  void _registerUser() async {
    String email = emailController.text.trim();
    String role = roleController.text.trim();

    if (email.isNotEmpty && role.isNotEmpty) {
      var user = await _authService.registerUserWithGeneratedPassword(
        email,
        role,
      );
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur ajouté et email envoyé !')),
        );
        emailController.clear();
        roleController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l’ajout de l’utilisateur')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter un utilisateur')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: roleController,
              decoration: InputDecoration(
                labelText: 'Rôle (admin, commercial, etc.)',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _registerUser, child: Text('Ajouter')),
          ],
        ),
      ),
    );
  }
}
