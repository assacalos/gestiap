import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/views/providers/clients_provider.dart';
import 'package:gestiap/features/commercial/views/providers/proforma_provider.dart';

class BordereauxProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<BordereauModel> _bordereaux = [];
  final List<Client> _clients = [];
  final List<QuoteModel> _quotes = [];

  bool isLoading = false;

  List<BordereauModel> get bordereaux => _bordereaux;
  List<Client> get clients => _clients;
  List<QuoteModel> get quotes => _quotes;

  final ClientProvider clientProvider;
  final QuoteProvider quoteProvider;

  BordereauxProvider(this.clientProvider, this.quoteProvider);

  /*  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    try {
      await Future.wait([fetchClients(), fetchQuotes(), fetchBordereaux()]);
    } catch (e) {
      print("Erreur init BordereauxProvider : $e");
    }

    isLoading = false;
    notifyListeners();
  } */

  Future<void> initialize() async {
    await fetchBordereaux();
  }

  Future<void> fetchClients() async {
    final result = await clientProvider.getClients();
    _clients.clear();
    _clients.addAll(result);
  }

  Future<void> fetchQuotes() async {
    final snapshot = await _firestore.collection('quotes').get();
    final validQuotes =
        snapshot.docs
            .map((doc) => QuoteModel.fromFirestore(doc))
            .where((q) => q.status.toLowerCase() == 'validé')
            .toList();
    _quotes.clear();
    _quotes.addAll(validQuotes);
  }

  Future<void> fetchBordereaux() async {
    isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('bordereaux').get();
      _bordereaux.clear();
      _bordereaux.addAll(
        snapshot.docs.map((doc) => BordereauModel.fromFirestore(doc)),
      );
    } catch (e) {
      print("Erreur lors de la récupération des bordereaux : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fonction pour enregistrer un bordereau comme brouillon
  Future<void> saveDraftBordereau(BordereauModel bordereau) async {
    try {
      await _firestore
          .collection('bordereaux')
          .doc(bordereau.id)
          .set(
            bordereau.toMap(),
            SetOptions(
              merge: true,
            ), // Fusionner les données si le document existe
          );

      int index = _bordereaux.indexWhere((b) => b.id == bordereau.id);
      if (index != -1) {
        _bordereaux[index] = bordereau;
      } else {
        _bordereaux.insert(0, bordereau);
      }
      notifyListeners();
    } catch (e) {
      print(
        'Erreur lors de l\'enregistrement du bordereau comme brouillon : $e',
      );
    }
  }

  // Fonction pour soumettre un bordereau
  Future<void> submitBordereau(String bordereauId) async {
    try {
      await _firestore.collection('bordereaux').doc(bordereauId).update({
        'status': BordereauModel.statusPendingValidation, // Statut mis à jour
      });
      final index = _bordereaux.indexWhere((b) => b.id == bordereauId);
      if (index != -1) {
        final updatedBordereau = _bordereaux[index].copyWith(
          status: BordereauModel.statusPendingValidation,
        );
        _bordereaux[index] = updatedBordereau;
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors de la soumission du bordereau : $e');
    }
  }

  Future<void> addBordereau(BordereauModel bordereau) async {
    await _firestore
        .collection('bordereaux')
        .doc(bordereau.id)
        .set(bordereau.toMap());
    _bordereaux.insert(0, bordereau);
    notifyListeners();
  }

  Future<void> updateBordereau(BordereauModel bordereau) async {
    await _firestore
        .collection('bordereaux')
        .doc(bordereau.id)
        .update(bordereau.toMap());
    final index = _bordereaux.indexWhere((b) => b.id == bordereau.id);
    if (index != -1) {
      _bordereaux[index] = bordereau;
      notifyListeners();
    }
  }

  Future<void> deleteBordereau(String id) async {
    await _firestore.collection('bordereaux').doc(id).delete();
    _bordereaux.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  Future<void> validateBordereau(String bordereauId) async {
    try {
      await _firestore.collection('bordereaux').doc(bordereauId).update({
        'status': BordereauModel.statusValidated,
      });
      final index = _bordereaux.indexWhere((b) => b.id == bordereauId);
      if (index != -1) {
        final updatedBordereau = _bordereaux[index].copyWith(
          status: BordereauModel.statusValidated,
        );
        _bordereaux[index] = updatedBordereau;
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors de la validation du bordereau : $e');
    }
  }

  Future<void> rejectBordereau(String bordereauId) async {
    try {
      await _firestore.collection('bordereaux').doc(bordereauId).update({
        'status': BordereauModel.statusRejected,
      });
      final index = _bordereaux.indexWhere((b) => b.id == bordereauId);
      if (index != -1) {
        final updatedBordereau = _bordereaux[index].copyWith(
          status: BordereauModel.statusRejected,
        );
        _bordereaux[index] = updatedBordereau;
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors du rejet du bordereau : $e');
    }
  }
}
