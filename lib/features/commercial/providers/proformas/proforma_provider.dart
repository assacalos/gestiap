import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/services/proformas/proforma_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gestiap/providers/auth_provider.dart';

class QuoteProvider with ChangeNotifier {
  final QuoteService _quoteService = QuoteService();
  List<QuoteModel> _quotes = [];
  bool _isLoading = true;
  String? _errorMessage;
  final AuthService _authService = AuthService(); // Utilisez AuthService

  List<QuoteModel> get quotes => _quotes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialisation du provider
  QuoteProvider() {
    loadQuotes(); // Charger les devis au démarrage du provider, une seule fois.
  }

  // Méthode publique pour charger les devis
  Future<void> loadQuotes() async {
    _loadQuotes(); // Appelle la méthode privée
  }

  // Méthode pour charger les devis du commercial connecté
  Future<void> _loadQuotes() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    try {
      //final authProvider = Provider.of<AppAuthProvider>(
      //  context,
      //  listen: false,
      //); // Utilisez votre AuthService
      final currentUserId =
          _authService.currentUser?.uid; // Utilisez AuthService
      if (currentUserId == null) {
        _errorMessage = "Utilisateur non connecté.";
        _isLoading = false;
        notifyListeners();
        return;
      }
      _quoteService
          .getQuotesStreamByCommercialId(currentUserId)
          .listen(
            (quoteList) {
              _quotes = quoteList;
              _isLoading = false;
              notifyListeners();
            },
            onError: (error) {
              _errorMessage = "Erreur lors du chargement des devis: $error";
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      _errorMessage = "Failed to load quotes: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllQuotes() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      _quoteService.getAllQuotesStream().listen(
        (quoteList) {
          _quotes = quoteList;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = "Erreur lors du chargement : $error";
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = "Erreur inattendue : $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter un nouveau devis
  Future<void> addQuote(QuoteModel quote) async {
    try {
      //final authProvider = Provider.of<AppAuthProvider>(
      //  context,
      //  listen: false,
      //); // Utilisez votre AuthService
      final currentUserId =
          _authService.currentUser?.uid; // Utilisez AuthService

      if (currentUserId != quote.commercialId) {
        throw Exception(
          "Un commercial ne peut ajouter un devis qu'à lui-même.",
        );
      }
      await _quoteService.addQuote(quote);
      // _quotes.add(quote);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to add quote: $e";
      notifyListeners();
      // _showErrorSnackbar(context, _errorMessage!); // Ne pas utiliser context
      rethrow; // Rethrow pour que l'UI puisse gérer l'erreur
    }
  }

  // Mettre à jour un devis
  Future<void> updateQuote(QuoteModel quote) async {
    try {
      final currentUserId =
          _authService.currentUser?.uid; // Utilisez AuthService
      final existingQuote = await _quoteService.getQuoteById(quote.id);
      if (existingQuote == null ||
          existingQuote.commercialId != currentUserId) {
        throw Exception("Vous n'êtes pas autorisé à modifier ce devis.");
      }
      await _quoteService.updateQuote(quote);
      final index = _quotes.indexWhere((q) => q.id == quote.id);
      if (index != -1) {
        _quotes[index] = quote;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to update quote: $e";
      notifyListeners();
      //_showErrorSnackbar(context, _errorMessage!); // Ne pas utiliser context
      rethrow;
    }
  }

  // Supprimer un devis
  Future<void> deleteQuote(String quoteId) async {
    try {
      final currentUserId =
          _authService.currentUser?.uid; // Utilisez AuthService
      final quoteToDelete = await _quoteService.getQuoteById(quoteId);
      if (quoteToDelete == null ||
          quoteToDelete.commercialId != currentUserId) {
        throw Exception("Vous n'êtes pas autorisé à supprimer ce devis.");
      }
      await _quoteService.deleteQuote(quoteId);
      _quotes.removeWhere((q) => q.id == quoteId);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to delete quote: $e";
      notifyListeners();
      //_showErrorSnackbar(context, _errorMessage!);  // Ne pas utiliser context
      rethrow;
    }
  }

  // Soumettre un devis
  Future<void> submitQuote(String quoteId) async {
    try {
      await _quoteService.submitQuote(quoteId);
      final index = _quotes.indexWhere((q) => q.id == quoteId);
      if (index != -1) {
        _quotes[index] = _quotes[index].copyWith(
          status: QuoteModel.statusPendingValidation,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to submit quote: $e";
      notifyListeners();
      //_showErrorSnackbar(context, _errorMessage!); // Ne pas utiliser context
      rethrow;
    }
  }

  // Valider un devis
  Future<void> validateQuote(String quoteId) async {
    try {
      await _quoteService.validateQuote(quoteId);
      final index = _quotes.indexWhere((q) => q.id == quoteId);
      if (index != -1) {
        _quotes[index] = _quotes[index].copyWith(
          status: QuoteModel.statusValidated,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to validate quote: $e";
      notifyListeners();
      //_showErrorSnackbar(context, _errorMessage!); // Ne pas utiliser context
      rethrow;
    }
  }

  // Rejeter un devis
  Future<void> rejectQuote(String quoteId, String commentaire) async {
    try {
      await _quoteService.rejectQuote(quoteId, commentaire);
      final index = _quotes.indexWhere((q) => q.id == quoteId);
      if (index != -1) {
        _quotes[index] = _quotes[index].copyWith(
          status: QuoteModel.statusRejected,
          commentaire: commentaire,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to reject quote: $e";
      notifyListeners();
      //_showErrorSnackbar(context, _errorMessage!); // Ne pas utiliser context
      rethrow;
    }
  }

  // Helper method to show snackbar
  // void _showErrorSnackbar(BuildContext context, String message) { // Retirer context
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text(message), backgroundColor: Colors.red),
  //   );
  // }
}
