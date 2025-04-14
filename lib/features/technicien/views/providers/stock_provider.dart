import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/technicien/data/models/stock_model.dart';

class StockProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<StockItem> _stockItems = [];
  bool isLoading = false;

  List<StockItem> get stockItems => _stockItems;

  Future<void> fetchStockItems() async {
    isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('stock').get();
      _stockItems =
          snapshot.docs.map((doc) {
            return StockItem.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
    } catch (e) {
      print("Erreur lors de la récupération du stock : $e");
      // Gérer l'erreur (afficher un message, etc.)
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStockItem(StockItem item) async {
    try {
      final docRef = await _firestore.collection('stock').add(item.toMap());
      final newItem = item.copyWith(id: docRef.id);
      _stockItems.add(newItem);
      notifyListeners();
      print('Produit ajouté au stock avec l\'ID : ${docRef.id}');
    } catch (e) {
      print("Erreur lors de l'ajout au stock : $e");
      // Gérer l'erreur
    }
  }

  Future<void> updateStockItem(StockItem updatedItem) async {
    try {
      await _firestore
          .collection('stock')
          .doc(updatedItem.id)
          .update(updatedItem.toMap());
      final index = _stockItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _stockItems[index] = updatedItem;
        notifyListeners();
        print('Produit avec l\'ID ${updatedItem.id} mis à jour.');
      }
    } catch (e) {
      print("Erreur lors de la mise à jour du stock : $e");
      // Gérer l'erreur
    }
  }

  Future<void> deleteStockItem(String itemId) async {
    try {
      await _firestore.collection('stock').doc(itemId).delete();
      _stockItems.removeWhere((item) => item.id == itemId);
      notifyListeners();
      print('Produit avec l\'ID $itemId supprimé du stock.');
    } catch (e) {
      print("Erreur lors de la suppression du stock : $e");
      // Gérer l'erreur
    }
  }

  // Vous pouvez ajouter ici des méthodes pour modifier et supprimer des articles du stock si nécessaire.

  Future<void> initialize() async {
    await fetchStockItems();
  }
}
