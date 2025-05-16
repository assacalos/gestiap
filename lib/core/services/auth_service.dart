import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Getter pour obtenir l'utilisateur actuel
  User? get currentUser {
    return _auth.currentUser;
  }

  // 🔹 Inscription avec email et mot de passe
  String generateRandomPassword({int length = 12}) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+';
    Random rand = Random();
    String password =
        List.generate(length, (index) {
          return characters[rand.nextInt(characters.length)];
        }).join();
    return password;
  }

  Future<User?> registerUserWithGeneratedPassword(
    String email,
    String role,
  ) async {
    try {
      // Générer un mot de passe aléatoire
      String password = generateRandomPassword();

      // Créer l'utilisateur avec le mot de passe généré
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Ajouter l'utilisateur dans Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Envoyer le mot de passe à l'utilisateur
      // await sendPasswordEmail(email, password);

      return userCredential.user;
    } catch (e) {
      print("Erreur lors de l'inscription: $e");
      return null;
    }
  }

  // 🔹 Connexion avec email et mot de passe
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Erreur lors de la connexion: $e");
      return null;
    }
  }

  // 🔹 Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 🔹 Obtenir l'utilisateur actuel
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<String?> getUserRole() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['role'] as String?;
    }

    return null;
  }

  /* Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        print('❌ Avertissement : Aucun document trouvé pour UID $uid.');
        return null;
      }

      var data = userDoc.data();
      print('📜 Données Firestore : $data');

      if (data is Map<String, dynamic> && data.containsKey('role')) {
        return data['role'];
      } else {
        print('❌ Erreur : Le champ "role" est absent.');
        return null;
      }
    } catch (e) {
      print('🚨 Erreur Firestore lors de la récupération du rôle : $e');
      return null;
    }
  } */

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Erreur lors de la réinitialisation du mot de passe : $e');
      rethrow; // Re-lance l'erreur pour que le code appelant puisse la gérer
    }
  }
}
