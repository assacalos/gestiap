import 'package:flutter_test/flutter_test.dart';
import 'package:gestiap/core/services/auth_service.dart';

void main() {
  test('Test de création d\'utilisateur', () async {
    // Appel à la méthode pour créer un utilisateur de test
    await createUserForTesting();
  });
}

Future<void> createUserForTesting() async {
  final _authService = AuthService();
  String email = "admin@example.com"; // Email de test
  String role =
      "admin"; // Rôle de test : "admin", "commercial", "comptable", "technicien"

  var user = await _authService.registerUserWithGeneratedPassword(email, role);
  if (user != null) {
    print('Utilisateur ${role} créé avec succès');
  } else {
    print('Erreur lors de la création de l\'utilisateur');
  }
}
//             nextScreen = LoginScreen(); // Redirection vers la page de connexion
//         }