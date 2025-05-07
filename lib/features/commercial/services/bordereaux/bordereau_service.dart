import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/core/services/auth_service.dart'; // Assurez-vous que le chemin est correct
import 'package:provider/provider.dart';

// *** Bordereau Service ***
class BordereauService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'bordereaux';

  // Récupérer un bordereau par ID
  Future<BordereauModel?> getBordereauById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return BordereauModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Erreur getBordereauById : $e");
      rethrow;
    }
  }

  // Récupérer les bordereaux d'un commercial
  Stream<List<BordereauModel>> getBordereauxStreamByCommercialId(
    String commercialId,
  ) {
    return _firestore
        .collection(_collectionName)
        .where('commercialId', isEqualTo: commercialId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BordereauModel.fromFirestore(doc))
              .toList();
        });
  }

  // Ajouter un bordereau
  Future<void> addBordereau(BordereauModel bordereau) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(bordereau.toMap());
      // Créez une nouvelle instance de BordereauModel avec l'ID correct.
      final newBordereau = bordereau.copyWith(id: docRef.id);

      // Mettez à jour le document Firestore avec les données, y compris l'ID.
      await _firestore
          .collection(_collectionName)
          .doc(docRef.id)
          .set(newBordereau.toMap());
      bordereau.id = docRef.id; //Mise à jour de l'id du bordereau
    } catch (e) {
      print("Erreur addBordereau : $e");
      rethrow;
    }
  }

  // Mettre à jour un bordereau
  Future<void> updateBordereau(BordereauModel bordereau) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(bordereau.id)
          .update(bordereau.toMap());
    } catch (e) {
      print("Erreur updateBordereau : $e");
      rethrow;
    }
  }

  // Supprimer un bordereau
  Future<void> deleteBordereau(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      print("Erreur deleteBordereau : $e");
      rethrow;
    }
  }

  // Soumettre un bordereau
  Future<void> submitBordereau(String bordereauId) async {
    try {
      await _firestore.collection(_collectionName).doc(bordereauId).update({
        'status': BordereauModel.statusSubmitted,
      });
    } catch (e) {
      print("Erreur submitBordereau : $e");
      rethrow;
    }
  }

  // Valider un bordereau
  Future<void> validateBordereau(String bordereauId) async {
    try {
      await _firestore.collection(_collectionName).doc(bordereauId).update({
        'status': BordereauModel.statusValidated,
      });
    } catch (e) {
      print("Erreur validateBordereau : $e");
      rethrow;
    }
  }

  // Rejeter un bordereau
  Future<void> rejectBordereau(String bordereauId, String commentaire) async {
    try {
      await _firestore.collection(_collectionName).doc(bordereauId).update({
        'status': BordereauModel.statusRejected,
        'commentaire': commentaire,
      });
    } catch (e) {
      print("Erreur rejectBordereau : $e");
      rethrow;
    }
  }
}
