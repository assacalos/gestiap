import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/commercial/data/models/bon_commande.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class BonDeCommandeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<BonDeCommandeModel> _bonsDeCommande = [];
  bool _isLoading = false;

  List<BonDeCommandeModel> get bonsDeCommande => _bonsDeCommande;
  bool get isLoading => _isLoading;

  Future<void> fetchBonsDeCommande(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore
              .collection('bonsDeCommande')
              .where(
                'commercialId',
                isEqualTo: currentUserId,
              ) // Filtrer par commercial
              .get();
      _bonsDeCommande =
          snapshot.docs
              .map((doc) => BonDeCommandeModel.fromFirestore(doc))
              .toList();
    } catch (e) {
      print("Erreur lors de la récupération des bons de commande : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBonsDeCommandePourPatron(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore
              .collection('bonsDeCommande')
              .where(
                'status',
                isEqualTo: BonDeCommandeModel.statusSoumisPatron,
              ) // Filtrer par statut
              .get();
      _bonsDeCommande =
          snapshot.docs
              .map((doc) => BonDeCommandeModel.fromFirestore(doc))
              .toList();
    } catch (e) {
      print(
        "Erreur lors de la récupération des bons de commande pour le patron : $e",
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBonDeCommande(
    BuildContext context,
    BonDeCommandeModel bonDeCommande,
    double totalProforma,
  ) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;

    if (currentUserId != null) {
      final newBonDeCommande = bonDeCommande.copyWith(
        createdAt: DateTime.now(),
        status:
            bonDeCommande.acompteRecu < totalProforma
                ? BonDeCommandeModel
                    .statusSoumisPatron // Soumis pour validation si acompte incomplet
                : BonDeCommandeModel
                    .statusValide, // Validé automatiquement si acompte total
      );
      try {
        final docRef = await _firestore.collection('bonsDeCommande').add({
          ...newBonDeCommande.toMap(),
          'commercialId': currentUserId,
        });
        final addedBonDeCommande = newBonDeCommande.copyWith(id: docRef.id);
        _bonsDeCommande.add(addedBonDeCommande);
        notifyListeners();
        print('Bon de commande ajouté avec succès!');
      } catch (e) {
        print('Erreur lors de l\'ajout du bon de commande: $e');
      }
    }
  }

  Future<void> updateBonDeCommande(
    BonDeCommandeModel bonDeCommande,
    double totalProforma,
  ) async {
    final updatedBonDeCommande = bonDeCommande.copyWith(
      status:
          bonDeCommande.acompteRecu < totalProforma
              ? BonDeCommandeModel.statusSoumisPatron
              : BonDeCommandeModel.statusValide,
    );
    try {
      await _firestore
          .collection('bonsDeCommande')
          .doc(bonDeCommande.id)
          .update(updatedBonDeCommande.toMap());
      final index = _bonsDeCommande.indexWhere((b) => b.id == bonDeCommande.id);
      if (index != -1) {
        _bonsDeCommande[index] = updatedBonDeCommande;
      }
      notifyListeners();
      print('Bon de commande mis à jour avec succès!');
    } catch (e) {
      print('Erreur lors de la mise à jour du bon de commande: $e');
    }
  }

  Future<void> validerBonDeCommandeParPatron(String bonDeCommandeId) async {
    try {
      await _firestore.collection('bonsDeCommande').doc(bonDeCommandeId).update(
        {'status': BonDeCommandeModel.statusValide},
      );
      final index = _bonsDeCommande.indexWhere((b) => b.id == bonDeCommandeId);
      if (index != -1) {
        _bonsDeCommande[index] = _bonsDeCommande[index].copyWith(
          status: BonDeCommandeModel.statusValide,
        );
        notifyListeners();
      }
    } catch (e) {
      print(
        'Erreur lors de la validation du bon de commande par le patron: $e',
      );
    }
  }

  Future<void> rejeterBonDeCommandeParPatron(
    String bonDeCommandeId,
    String commentaire,
  ) async {
    try {
      await _firestore.collection('bonsDeCommande').doc(bonDeCommandeId).update(
        {
          'status': BonDeCommandeModel.statusRejete,
          'commentairePatron': commentaire,
        },
      );
      final index = _bonsDeCommande.indexWhere((b) => b.id == bonDeCommandeId);
      if (index != -1) {
        _bonsDeCommande[index] = _bonsDeCommande[index].copyWith(
          status: BonDeCommandeModel.statusRejete,
          commentairePatron: commentaire,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors du rejet du bon de commande par le patron: $e');
    }
  }

  // Fonction pour récupérer un bon de commande par ID (utile pour l'affichage)
  BonDeCommandeModel? getBonDeCommandeById(String id) {
    return _bonsDeCommande.firstWhere(
      (b) => b.id == id,
      orElse:
          () => BonDeCommandeModel(
            id: id,
            clientId: '',
            bordereauId: '',
            proformaId: '',
            documentScanneUrl: null,
            acompteRecu: 0.0,
            createdAt: DateTime.now(),
            status: BonDeCommandeModel.statusDraft,
          ),
    );
  }
}
