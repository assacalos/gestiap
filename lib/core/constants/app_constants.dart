import 'package:flutter/material.dart';

class AppConstants {
  // Nom de l'application
  static const String appName = 'GestApp';
  static const String clients = 'clients';
  // static const String users = 'users'; // Si tu as une collection pour les utilisateurs
  // static const String commandes = 'commandes';
  // static const String produits = 'produits';
  // etc.

  // Couleurs de l'application
  static const primaryColor = Colors.blue;
  static const secondaryColor = Colors.green;
  static const backgroundColor = Colors.white;
  static const textColor = Colors.black;

  // Textes par défaut
  static const defaultErrorMessage = 'Une erreur est survenue.';
  static const loadingMessage = 'Chargement...';
  static const noDataMessage = 'Aucune donnée disponible.';

  // Tailles de police
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;

  // Espacements
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Routes de navigation
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String clientsRoute = '/clients';
  static const String devisRoute = '/devis';
  static const String bordereauxRoute = '/bordereaux';
  // ... Ajoutez d'autres routes

  // Rôles d'utilisateur
  static const String commercialRole = 'commercial';
  static const String patronRole = 'patron';
  static const String comptableRole = 'comptable';
  static const String technicienRole = 'technicien';
  // ... Ajoutez d'autres rôles

  // Clés de stockage (par exemple, pour les préférences partagées)
  static const String userTokenKey = 'user_token';
  static const String userRoleKey = 'user_role';

  // Autres constantes (par exemple, les URL d'API)
  static const String baseUrl = 'https://api.votre-entreprise.com';
  static const String clientsEndpoint = '/clients';
  static const String devisEndpoint = '/devis';
  static const String bordereauxEndpoint = '/bordereaux';
  // ... Ajoutez d'autres endpoints
}
