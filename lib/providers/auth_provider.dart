import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';
import '../core/constants/app_constants.dart';
import '../features/commercial/views/pages/commercial_dashboard_page.dart';

class AppAuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _userRole;
  bool _isLoggedIn = false; // Déclaration de _isLoggedIn
  bool _isLoading = false;

  User? get user => _user;
  String? get userRole => _userRole;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  void setUserRole(String? role) {
    _userRole = role;
    _isLoggedIn =
        role != null; // Si le rôle est défini, l'utilisateur est connecté
    notifyListeners();
  }

  AuthProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    _user = _authService.getCurrentUser();
    if (_user != null) {
      _userRole = await _authService.getUserRole(_user!.uid);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      User? user = await _authService.loginUser(email, password);
      if (user != null) {
        _user = user;
        _userRole = await _authService.getUserRole(_user!.uid);

        print(
          'Utilisateur connecté : ${_user!.email}, rôle : $_userRole',
        ); // 🛠️ Debug

        _isLoading = false;
        notifyListeners();
        return _userRole;
      }
    } catch (e) {
      print('Erreur de connexion : $e');
    }

    print('Connexion échouée.'); // ✅ Voir si ce message s'affiche
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> register(String email, String password, String role) async {
    _isLoading = true;
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
      }
    } catch (e) {
      print('Erreur d\'enregistrement : $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _user = null;
    _userRole = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
    } catch (e) {
      print('Erreur de réinitialisation du mot de passe : $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
