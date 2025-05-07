import 'package:flutter/material.dart';
import 'package:gestiap/features/technicien/data/models/equipements_model.dart';
import 'package:gestiap/features/technicien/services/equipement_service.dart';

class EquipementProvider extends ChangeNotifier {
  final EquipementService _equipementService = EquipementService();

  List<EquipementModel> _equipements = [];
  List<EquipementModel> get equipements => _equipements;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> getEquipements() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _equipements = await _equipementService.getAllEquipements();
    } catch (e) {
      _error = "Erreur lors de la récupération des équipements : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<EquipementModel?> getEquipementById(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final EquipementModel? equipement = await _equipementService
          .getEquipementById(id);
      _loading = false;
      notifyListeners();
      return equipement;
    } catch (e) {
      _error = "Erreur lors de la récupération de l'équipement par ID : $e";
      print(_error);
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> addEquipement(EquipementModel equipement) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _equipementService.addEquipement(equipement);
      _equipements.add(equipement);
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de l'ajout de l'équipement : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateEquipement(EquipementModel equipement) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _equipementService.updateEquipement(equipement);
      final index = _equipements.indexWhere(
        (element) => element.id == equipement.id,
      );
      if (index != -1) {
        _equipements[index] = equipement;
      }
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de la mise à jour de l'équipement : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEquipement(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _equipementService.deleteEquipement(id);
      _equipements.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de la suppression de l'équipement : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
