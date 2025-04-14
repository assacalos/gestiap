import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/comptable/data/models/budget_model.dart';

class BudgetProvider extends ChangeNotifier {
  List<BudgetModel> _budgets = [];
  bool _isLoading = false;

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'budgets';

  Future<void> loadBudgets() async {
    _isLoading = true;
    notifyListeners();
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(_collection).get();
      _budgets =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return BudgetModel.fromJson(data)..id = doc.id;
          }).toList();
    } catch (error) {
      print('Erreur lors du chargement des budgets : $error');
      // Gérer l'erreur ici
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBudget(BudgetModel budget) async {
    try {
      final DocumentReference<Map<String, dynamic>> docRef = await _firestore
          .collection(_collection)
          .add(budget.toJson());
      budget.id = docRef.id;
      _budgets.add(budget);
      notifyListeners();
    } catch (error) {
      print('Erreur lors de l\'ajout du budget : $error');
      // Gérer l'erreur ici
    }
  }

  Future<void> updateBudget(BudgetModel budget) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(budget.id)
          .update(budget.toJson());
      final index = _budgets.indexWhere((bud) => bud.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
        notifyListeners();
      }
    } catch (error) {
      print('Erreur lors de la mise à jour du budget : $error');
      // Gérer l'erreur ici
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      await _firestore.collection(_collection).doc(budgetId).delete();
      _budgets.removeWhere((bud) => bud.id == budgetId);
      notifyListeners();
    } catch (error) {
      print('Erreur lors de la suppression du budget : $error');
      // Gérer l'erreur ici
    }
  }
}
