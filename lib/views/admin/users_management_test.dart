import 'package:flutter/material.dart';
import 'package:gestiap/core/services/auth_service.dart';

class UserManagement {
  static Future<void> createUserForTesting() async {
    final _authService = AuthService();
    String email = "admin@example.com"; // Email de test
    String role =
        "admin"; // Rôle de test : "admin", "commercial", "comptable", "technicien"

    var user = await _authService.registerUserWithGeneratedPassword(
      email,
      role,
    );
    if (user != null) {
      print('Utilisateur ${role} créé avec succès');
    } else {
      print('Erreur lors de la création de l\'utilisateur');
    }
  }
}
