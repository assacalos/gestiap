import 'package:flutter/material.dart';
import 'package:gestiap/features/rh/data/models/employes_model.dart';
import 'package:gestiap/features/rh/services/employe_service.dart';

class EmployeProvider extends ChangeNotifier {
  final EmployeService _employeService = EmployeService();

  List<EmployeModel> _employes = [];
  List<EmployeModel> get employes => _employes;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> getEmployes() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _employes = await _employeService.getAllEmployes();
    } catch (e) {
      _error = "Erreur lors de la récupération des employés : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<EmployeModel?> getEmployeById(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final EmployeModel? employe = await _employeService.getEmployeById(id);
      _loading = false;
      notifyListeners();
      return employe;
    } catch (e) {
      _error = "Erreur lors de la récupération de l'employé par ID : $e";
      print(_error);
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> addEmploye(EmployeModel employe) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _employeService.addEmploye(employe);
      _employes.add(employe);
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de l'ajout de l'employé : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateEmploye(EmployeModel employe) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _employeService.updateEmploye(employe);
      final index = _employes.indexWhere((element) => element.id == employe.id);
      if (index != -1) {
        _employes[index] = employe;
      }
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de la mise à jour de l'employé : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEmploye(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _employeService.deleteEmploye(id);
      _employes.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de la suppression de l'employé : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
