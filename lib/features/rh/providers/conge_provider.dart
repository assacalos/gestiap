import 'package:flutter/material.dart';
import 'package:gestiap/features/rh/data/models/conges_model.dart';
import 'package:gestiap/features/rh/services/conge_service.dart';

class CongeProvider extends ChangeNotifier {
  final CongeService _congeService = CongeService();

  List<CongeModel> _conges = [];
  List<CongeModel> get conges => _conges;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> getConges() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _conges = await _congeService.getAllConges();
    } catch (e) {
      _error = "Erreur lors de la récupération des congés : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> getCongesByEmployeId(String employeId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _conges = await _congeService.getCongesByEmployeId(employeId);
    } catch (e) {
      _error =
          "Erreur lors de la récupération des congés pour l'employé $employeId: $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addConge(CongeModel conge) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _congeService.addConge(conge);
      _conges.add(conge);
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de l'ajout du congé : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateConge(CongeModel conge) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _congeService.updateConge(conge);
      final index = _conges.indexWhere((element) => element.id == conge.id);
      if (index != -1) {
        _conges[index] = conge;
      }
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de la mise à jour du congé : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteConge(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _congeService.deleteConge(id);
      _conges.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de la suppression du congé : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<CongeModel?> getCongeById(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final CongeModel? conge = await _congeService.getCongeById(id);
      _loading = false;
      notifyListeners();
      return conge;
    } catch (e) {
      _error = "Erreur lors de la récupération du congé par ID : $e";
      print(_error);
      _loading = false;
      notifyListeners();
      return null;
    }
  }
}
