import 'package:flutter/material.dart';
import 'package:gestiap/features/technicien/data/models/interventions_model.dart';
import 'package:gestiap/features/technicien/services/interventions_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//     try {

class InterventionProvider extends ChangeNotifier {
  final InterventionService _interventionService = InterventionService();

  List<InterventionModel> _interventions = [];
  List<InterventionModel> get interventions => _interventions;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> getInterventions() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _interventions = await _interventionService.getAllInterventions();
    } catch (e) {
      _error = "Erreur lors de la récupération des interventions : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<InterventionModel?> getInterventionById(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final InterventionModel? intervention = await _interventionService
          .getInterventionById(id);
      _loading = false;
      notifyListeners();
      return intervention;
    } catch (e) {
      _error = "Erreur lors de la récupération de l'intervention par ID : $e";
      print(_error);
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> addIntervention(InterventionModel intervention) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _interventionService.addIntervention(intervention);
      _interventions.add(intervention);
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de l'ajout de l'intervention : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateIntervention(InterventionModel intervention) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _interventionService.updateIntervention(intervention);
      final index = _interventions.indexWhere(
        (element) => element.id == intervention.id,
      );
      if (index != -1) {
        _interventions[index] = intervention;
      }
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de la mise à jour de l'intervention : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteIntervention(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _interventionService.deleteIntervention(id);
      _interventions.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de la suppression de l'intervention : $e";
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
