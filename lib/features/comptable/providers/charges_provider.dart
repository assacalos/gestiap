import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/comptable/data/models/charge_model.dart';

class ChargesProvider extends ChangeNotifier {
  List<ChargesModel> _charges = [];
  bool _isLoading = false;

  List<ChargesModel> get charges => _charges;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'charges';

  Future<void> loadCharges() async {
    _isLoading = true;
    notifyListeners();
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore
              .collection(_collection)
              .orderBy('date', descending: true)
              .get();
      _charges =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return ChargesModel.fromJson(data)..id = doc.id;
          }).toList();
    } catch (error) {
      print('Erreur lors du chargement des charges : $error');
      // Gérer l'erreur ici
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCharges(ChargesModel charge) async {
    try {
      final DocumentReference<Map<String, dynamic>> docRef = await _firestore
          .collection(_collection)
          .add(charge.toJson());
      charge.id = docRef.id;
      _charges.add(charge);
      notifyListeners();
    } catch (error) {
      print('Erreur lors de l\'ajout de la dépense : $error');
      // Gérer l'erreur ici
    }
  }

  Future<void> updateCharge(ChargesModel charge) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(charge.id)
          .update(charge.toJson());
      final index = _charges.indexWhere((dep) => dep.id == charge.id);
      if (index != -1) {
        _charges[index] = charge;
        notifyListeners();
      }
    } catch (error) {
      print('Erreur lors de la mise à jour de la dépense : $error');
      // Gérer l'erreur ici
    }
  }

  Future<void> deleteCharge(String chargeId) async {
    try {
      await _firestore.collection(_collection).doc(chargeId).delete();
      _charges.removeWhere((dep) => dep.id == chargeId);
      notifyListeners();
    } catch (error) {
      print('Erreur lors de la suppression de la dépense : $error');
      // Gérer l'erreur ici
    }
  }
}
