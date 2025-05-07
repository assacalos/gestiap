import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/data/models/etat_financier_model.dart';
import 'package:gestiap/features/comptable/services/etat_financier_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EtatFinancierProvider extends ChangeNotifier {
  final EtatFinancierService _etatFinancierService = EtatFinancierService();

  List<EtatFinancierModel> _etatsFinanciers = [];
  List<EtatFinancierModel> get etatsFinanciers => _etatsFinanciers;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> getEtatsFinanciers() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _etatsFinanciers = await _etatFinancierService.getAllEtatsFinanciers();
    } catch (e) {
      _error = "Erreur lors de la récupération des états financiers : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addEtatFinancier(EtatFinancierModel etatFinancier) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _etatFinancierService.addEtatFinancier(etatFinancier);
      _etatsFinanciers.add(etatFinancier);
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de l'ajout de l'état financier : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateEtatFinancier(EtatFinancierModel etatFinancier) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _etatFinancierService.updateEtatFinancier(etatFinancier);
      final index = _etatsFinanciers.indexWhere(
        (element) => element.id == etatFinancier.id,
      );
      if (index != -1) {
        _etatsFinanciers[index] = etatFinancier;
      }
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de la mise à jour de l'état financier : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEtatFinancier(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _etatFinancierService.deleteEtatFinancier(id);
      _etatsFinanciers.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de la suppression de l'état financier : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<EtatFinancierModel?> getEtatFinancierById(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final EtatFinancierModel? etatFinancier = await _etatFinancierService
          .getEtatFinancierById(id);
      _loading = false;
      notifyListeners();
      return etatFinancier;
    } catch (e) {
      _error = "Erreur lors de la récupération de l'état financier par ID : $e";
      print(_error);
      _loading = false;
      notifyListeners();
      return null;
    }
  }
}
