import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart'; // Assurez-vous que le chemin est correct
import '../core/constants/app_constants.dart'; // Assurez-vous que le chemin est correct
import '../features/commercial/views/pages/commercial_dashboard_page.dart'; // Assurez-vous que le chemin est correct

class AppAuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _userRole;
  // bool _isLoggedIn = false; // Inutile, car on peut déduire cela de _user
  bool _isLoading = false;
  String? _errorMessage; // Pour stocker les messages d'erreur

  User? get user => _user;
  String? get userRole => _userRole;
  bool get isLoggedIn =>
      _user !=
      null; // Plus simple : si _user est non-null, alors l'utilisateur est connecté
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage; // Getter pour le message d'erreur

  void setUserRole(String? role) {
    _userRole = role;
    notifyListeners();
  }

  AppAuthProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    _errorMessage = null; // Réinitialiser le message d'erreur
    notifyListeners();

    try {
      _user = _authService.getCurrentUser();
      if (_user != null) {
        _userRole = await _authService.getUserRole(_user!.uid);
      }
    } catch (e) {
      _errorMessage =
          'Erreur lors du chargement de l\'utilisateur actuel : $e'; // Message d'erreur clair
      print(_errorMessage); // Toujours logger l'erreur
      _user = null; // IMPORTANT : Mettre _user à null en cas d'erreur
      _userRole = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null; // Réinitialiser le message d'erreur
    notifyListeners();

    try {
      User? user = await _authService.loginUser(email, password);
      if (user != null) {
        _user = user;
        _userRole = await _authService.getUserRole(_user!.uid);
        _isLoading = false;
        notifyListeners();
        return _userRole;
      } else {
        _errorMessage = 'Identifiants invalides.'; // Message d'erreur clair
        _isLoading = false;
        notifyListeners();
        return null; // Retourner null pour indiquer un échec
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion : $e'; // Message d'erreur clair
      print(_errorMessage); // IMPORTANT : Log l'erreur
      _isLoading = false;
      notifyListeners();
      return null; // Retourner null en cas d'erreur
    }
  }

  Future<bool> register(String email, String password, String role) async {
    _isLoading = true;
    _errorMessage = null; // Réinitialiser le message d'erreur
    notifyListeners();

    try {
      User? user = await _authService.registerUserWithGeneratedPassword(
        email,
        role,
      );
      if (user != null) {
        _user = user;
        _userRole = role;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'L\'enregistrement a échoué.'; // Message d'erreur clair
        _isLoading = false;
        notifyListeners();
        return false; // Retourner false
      }
    } catch (e) {
      _errorMessage = 'Erreur d\'enregistrement : $e'; // Message d'erreur clair
      print(_errorMessage); // IMPORTANT : Log l'erreur
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null; // Réinitialiser
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _userRole = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la déconnexion : $e';
      print(_errorMessage);
      _isLoading = false;
      notifyListeners(); // Ne pas oublier de notifier les listeners même en cas d'erreur
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
    } catch (e) {
      _errorMessage = 'Erreur de réinitialisation du mot de passe : $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
