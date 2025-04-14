import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/comptable/data/models/charge_model.dart';

class DepenseProvider extends ChangeNotifier {
  List<DepenseModel> _depenses = [];
  bool _isLoading = false;

  List<DepenseModel> get depenses => _depenses;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'depenses';

  Future<void> loadDepenses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore
              .collection(_collection)
              .orderBy('date', descending: true)
              .get();
      _depenses =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return DepenseModel.fromJson(data)..id = doc.id;
          }).toList();
    } catch (error) {
      print('Erreur lors du chargement des dépenses : $error');
      // Gérer l'erreur ici
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDepense(DepenseModel depense) async {
    try {
      final DocumentReference<Map<String, dynamic>> docRef = await _firestore
          .collection(_collection)
          .add(depense.toJson());
      depense.id = docRef.id;
      _depenses.add(depense);
      notifyListeners();
    } catch (error) {
      print('Erreur lors de l\'ajout de la dépense : $error');
      // Gérer l'erreur ici
    }
  }

  Future<void> updateDepense(DepenseModel depense) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(depense.id)
          .update(depense.toJson());
      final index = _depenses.indexWhere((dep) => dep.id == depense.id);
      if (index != -1) {
        _depenses[index] = depense;
        notifyListeners();
      }
    } catch (error) {
      print('Erreur lors de la mise à jour de la dépense : $error');
      // Gérer l'erreur ici
    }
  }

  Future<void> deleteDepense(String depenseId) async {
    try {
      await _firestore.collection(_collection).doc(depenseId).delete();
      _depenses.removeWhere((dep) => dep.id == depenseId);
      notifyListeners();
    } catch (error) {
      print('Erreur lors de la suppression de la dépense : $error');
      // Gérer l'erreur ici
    }
  }
}
