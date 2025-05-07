import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/data/models/impot_taxes_model.dart';
import 'package:gestiap/features/comptable/services/impot_taxe_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/core/constants/app_constants.dart';

class ImpotTaxeProvider extends ChangeNotifier {
  final ImpotTaxeService _impotTaxeService = ImpotTaxeService();

  List<ImpotTaxeModel> _impotsTaxes = [];
  List<ImpotTaxeModel> get impotsTaxes => _impotsTaxes;

  bool _loading = false;
  bool get loading => _loading;

  String? _error; // Pour stocker les messages d'erreur
  String? get error => _error;

  // Méthode pour récupérer tous les impôts/taxes
  Future<void> getImpotsTaxes() async {
    _loading = true;
    _error = null; // Réinitialiser l'erreur à chaque appel
    notifyListeners();
    try {
      _impotsTaxes = await _impotTaxeService.getAllImpotsTaxes();
    } catch (e) {
      _error = "Erreur lors de la récupération des impôts/taxes : $e";
      // Log l'erreur
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Méthode pour ajouter un impôt/taxe
  Future<void> addImpotTaxe(ImpotTaxeModel impotTaxe) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _impotTaxeService.addImpotTaxe(impotTaxe);
      _impotsTaxes.add(impotTaxe); // Ajouter à la liste locale
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de l'ajout de l'impôt/taxe : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Méthode pour mettre à jour un impôt/taxe
  Future<void> updateImpotTaxe(ImpotTaxeModel impotTaxe) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _impotTaxeService.updateImpotTaxe(impotTaxe);
      // Mettre à jour dans la liste locale
      final index = _impotsTaxes.indexWhere(
        (element) => element.id == impotTaxe.id,
      );
      if (index != -1) {
        _impotsTaxes[index] = impotTaxe;
      }
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de la mise à jour de l'impôt/taxe : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Méthode pour supprimer un impôt/taxe
  Future<void> deleteImpotTaxe(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _impotTaxeService.deleteImpotTaxe(id);
      // Supprimer de la liste locale
      _impotsTaxes.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de la suppression de l'impôt/taxe : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Méthode pour récupérer un impôt/taxe par ID (optionnel)
  Future<ImpotTaxeModel?> getImpotTaxeById(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final ImpotTaxeModel? impotTaxe = await _impotTaxeService
          .getImpotTaxeById(id);
      _loading = false;
      notifyListeners();
      return impotTaxe;
    } catch (e) {
      _error = "Erreur lors de la récupération de l'impôt/taxe par ID : $e";
      print(_error);
      _loading = false;
      notifyListeners();
      return null;
    }
  }
}
