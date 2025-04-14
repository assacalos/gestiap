import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clients_provider.dart';
import 'package:gestiap/core/services/auth_service.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class QuoteProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QuoteModel> _quotes = [];
  bool isLoading = false;

  List<QuoteModel> get quotes => _quotes;

  Future<void> fetchQuotes() async {
    final snapshot = await _firestore.collection('quotes').get();
    _quotes =
        snapshot.docs.map((doc) => QuoteModel.fromFirestore(doc)).toList();
    notifyListeners();
  }

  // Fonction pour enregistrer un devis comme brouillon
  Future<void> saveDraftQuote(QuoteModel quote) async {
    try {
      await _firestore
          .collection('quotes')
          .doc(quote.id)
          .set(
            quote.toMap(),
            SetOptions(
              merge: true,
            ), // Fusionner les données si le document existe déjà
          );

      int index = _quotes.indexWhere((q) => q.id == quote.id);
      if (index != -1) {
        _quotes[index] = quote;
      } else {
        _quotes.add(quote);
      }
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'enregistrement du devis comme brouillon : $e');
    }
  }

  // Fonction pour soumettre un devis pour validation
  Future<void> submitQuote(String quoteId) async {
    try {
      await _firestore.collection('quotes').doc(quoteId).update({
        'status': QuoteModel.statusPendingValidation, // Statut mis à jour
      });
      final index = _quotes.indexWhere((q) => q.id == quoteId);
      if (index != -1) {
        final updatedQuote = _quotes[index].copyWith(
          status: QuoteModel.statusPendingValidation,
        );
        _quotes[index] = updatedQuote;
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors de la soumission du devis : $e');
    }
  }

  Future<List<QuoteModel>> getQuotes() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('quotes').get();
      List<QuoteModel> quotes =
          querySnapshot.docs
              .map((doc) => QuoteModel.fromFirestore(doc))
              .toList();
      return quotes;
    } catch (e) {
      print('Erreur lors de la récupération des devis: $e');
      return []; // Retourne une liste vide en cas d'erreur
    }
  }

  Future<void> updateQuote(QuoteModel quote) async {
    await _firestore.collection('quotes').doc(quote.id).update(quote.toMap());
    int index = _quotes.indexWhere((q) => q.id == quote.id);
    if (index != -1) {
      _quotes[index] = quote;
      notifyListeners();
    }
  }

  Future<void> deleteQuote(String quoteId) async {
    try {
      await _firestore.collection('quotes').doc(quoteId).delete();

      // Mettre à jour la liste locale des devis
      _quotes.removeWhere((quote) => quote.id == quoteId);
      notifyListeners();
      print('Devis avec l\'ID $quoteId supprimé.');
    } catch (e) {
      print('Erreur lors de la suppression du devis $quoteId: $e');
      // Gérer l'erreur (afficher un message à l'utilisateur)
    }
  }

  // Appeler cette méthode automatiquement
  Future<void> initialize() async {
    await fetchQuotes();
  }

  Future<void> validateQuote(String quoteId) async {
    try {
      await _firestore.collection('quotes').doc(quoteId).update({
        'status': QuoteModel.statusValidated,
      });
      final index = _quotes.indexWhere((q) => q.id == quoteId);
      if (index != -1) {
        final updatedQuote = _quotes[index].copyWith(
          status: QuoteModel.statusValidated,
        );
        _quotes[index] = updatedQuote;
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors de la validation du devis : $e');
    }
  }

  Future<void> rejectQuote(String quoteId) async {
    try {
      await _firestore.collection('quotes').doc(quoteId).update({
        'status': QuoteModel.statusRejected,
      });
      final index = _quotes.indexWhere((q) => q.id == quoteId);
      if (index != -1) {
        final updatedQuote = _quotes[index].copyWith(
          status: QuoteModel.statusRejected,
        );
        _quotes[index] = updatedQuote;
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors du rejet du devis : $e');
    }
  }
}
