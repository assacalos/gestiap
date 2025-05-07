import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart'; // Assurez-vous que le chemin est correct
import 'package:gestiap/core/services/auth_service.dart'; // Assurez-vous que le chemin est correct
import 'package:provider/provider.dart';

// *** Quote Service ***
class QuoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'quotes'; // Utilisez une constante

  // Récupérer un devis par ID
  Future<QuoteModel?> getQuoteById(String quoteId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collectionName).doc(quoteId).get();
      if (doc.exists) {
        return QuoteModel.fromFirestore(doc);
      } else {
        return null; // Retourne null si le document n'existe pas
      }
    } catch (e) {
      print("Erreur lors de la récupération du devis : $e");
      rethrow;
    }
  }

  // Ajouter un nouveau devis
  Future<void> addQuote(QuoteModel quote) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(quote.toMap());
      quote.id = docRef.id; // Important : Mettre à jour l'ID du devis
      await docRef.update({'id': quote.id});
    } catch (e) {
      print("Erreur lors de l'ajout du devis : $e");
      rethrow;
    }
  }

  // Mettre à jour un devis existant
  Future<void> updateQuote(QuoteModel quote) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(quote.id)
          .update(quote.toMap());
    } catch (e) {
      print("Erreur lors de la mise à jour du devis : $e");
      rethrow;
    }
  }

  // Supprimer un devis
  Future<void> deleteQuote(String quoteId) async {
    try {
      await _firestore.collection(_collectionName).doc(quoteId).delete();
    } catch (e) {
      print("Erreur lors de la suppression du devis : $e");
      rethrow;
    }
  }

  // Soumettre un devis pour validation
  Future<void> submitQuote(String quoteId) async {
    try {
      await _firestore.collection(_collectionName).doc(quoteId).update({
        'status': QuoteModel.statusPendingValidation,
      });
    } catch (e) {
      print("Erreur lors de la soumission du devis : $e");
      rethrow;
    }
  }

  // Valider un devis
  Future<void> validateQuote(String quoteId) async {
    try {
      await _firestore.collection(_collectionName).doc(quoteId).update({
        'status': QuoteModel.statusValidated,
      });
    } catch (e) {
      print("Erreur lors de la validation du devis : $e");
      rethrow;
    }
  }

  // Rejeter un devis
  Future<void> rejectQuote(String quoteId, String commentaire) async {
    try {
      await _firestore.collection(_collectionName).doc(quoteId).update({
        'status': QuoteModel.statusRejected,
        'commentaire': commentaire,
      });
    } catch (e) {
      print("Erreur lors du rejet du devis : $e");
      rethrow;
    }
  }

  // Récupérer tous les devis d'un commercial
  Stream<List<QuoteModel>> getQuotesStreamByCommercialId(String commercialId) {
    return _firestore
        .collection(_collectionName)
        .where(
          'commercialId',
          isEqualTo: commercialId,
        ) // Filtrer par commercialId
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => QuoteModel.fromFirestore(doc))
              .toList();
        });
  }
}
