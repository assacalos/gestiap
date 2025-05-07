import 'package:flutter/material.dart';
import 'package:gestiap/features/technicien/data/models/rapport_intervention_model.dart';
import 'package:gestiap/features/technicien/services/rapport_intervention_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RapportInterventionProvider extends ChangeNotifier {
  final RapportInterventionService _rapportService =
      RapportInterventionService();

  List<RapportInterventionModel> _rapports = [];
  List<RapportInterventionModel> get rapports => _rapports;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> getRapportsIntervention() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _rapports = await _rapportService.getAllRapportsIntervention();
    } catch (e) {
      _error = "Erreur lors de la récupération des rapports : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<RapportInterventionModel?> getRapportInterventionById(
    String id,
  ) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final RapportInterventionModel? rapport = await _rapportService
          .getRapportInterventionById(id);
      _loading = false;
      notifyListeners();
      return rapport;
    } catch (e) {
      _error =
          "Erreur lors de la récupération du rapport d'intervention par ID : $e";
      print(_error);
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> addRapportIntervention(RapportInterventionModel rapport) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _rapportService.addRapportIntervention(rapport);
      _rapports.add(rapport);
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de l'ajout du rapport d'intervention : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateRapportIntervention(
    RapportInterventionModel rapport,
  ) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _rapportService.updateRapportIntervention(rapport);
      final index = _rapports.indexWhere((element) => element.id == rapport.id);
      if (index != -1) {
        _rapports[index] = rapport;
      }
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de la mise à jour du rapport d'intervention : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRapportIntervention(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _rapportService.deleteRapportIntervention(id);
      _rapports.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de la suppression du rapport d'intervention : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
