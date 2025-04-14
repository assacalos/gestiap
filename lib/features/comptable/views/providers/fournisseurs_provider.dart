import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/comptable/data/models/fournisseurs_model.dart';

class FournisseurProvider extends ChangeNotifier {
  List<FournisseurModel> _fournisseurs = [];
  bool _isLoading = false;

  List<FournisseurModel> get fournisseurs => _fournisseurs;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'fournisseurs';

  Future<void> loadFournisseurs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(_collection).get();
      _fournisseurs =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return FournisseurModel.fromJson(data)..id = doc.id;
          }).toList();
    } catch (error) {
      print('Erreur lors du chargement des fournisseurs : $error');
      // Gérer l'erreur ici
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFournisseur(FournisseurModel fournisseur) async {
    try {
      final DocumentReference<Map<String, dynamic>> docRef = await _firestore
          .collection(_collection)
          .add(fournisseur.toJson());
      fournisseur.id = docRef.id;
      _fournisseurs.add(fournisseur);
      notifyListeners();
    } catch (error) {
      print('Erreur lors de l\'ajout du fournisseur : $error');
      // Gérer l'erreur ici
    }
  }

  Future<void> updateFournisseur(FournisseurModel fournisseur) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(fournisseur.id)
          .update(fournisseur.toJson());
      final index = _fournisseurs.indexWhere((f) => f.id == fournisseur.id);
      if (index != -1) {
        _fournisseurs[index] = fournisseur;
        notifyListeners();
      }
    } catch (error) {
      print('Erreur lors de la mise à jour du fournisseur : $error');
      // Gérer l'erreur ici
    }
  }

  Future<void> deleteFournisseur(String fournisseurId) async {
    try {
      await _firestore.collection(_collection).doc(fournisseurId).delete();
      _fournisseurs.removeWhere((f) => f.id == fournisseurId);
      notifyListeners();
    } catch (error) {
      print('Erreur lors de la suppression du fournisseur : $error');
      // Gérer l'erreur ici
    }
  }
}
