import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/services/bordereaux/bordereau_service.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';

class BordereauxProvider extends ChangeNotifier {
  final BordereauService _bordereauService = BordereauService();
  List<BordereauModel> _bordereaux = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BordereauModel> get bordereaux => _bordereaux;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ClientProvider clientProvider;
  final QuoteProvider quoteProvider;
  BuildContext context;

  BordereauxProvider({
    required this.clientProvider,
    required this.quoteProvider,
    required this.context,
  }) {
    print("BordereauxProvider created"); // Ajout de ce print
    loadBordereaux(context);
  }

  // Méthode pour charger les bordereaux du commercial connecté
  Future<void> loadBordereaux(BuildContext context) async {
    print("loadBordereaux called"); // Ajout de ce print
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.uid;

      if (currentUserId == null) {
        _errorMessage = "Utilisateur non connecté.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      _bordereauService
          .getBordereauxStreamByCommercialId(currentUserId)
          .listen(
            (bordereauList) {
              _bordereaux = bordereauList;
              _isLoading = false;
              notifyListeners();
              print("Bordereaux loaded: ${_bordereaux.length}"); // Ajout
            },
            onError: (error) {
              // Ajout pour gérer les erreurs de stream
              _errorMessage = "Erreur de stream : $error";
              _isLoading = false;
              notifyListeners();
              print("Error in bordereaux stream: $error");
            },
            onDone: () {
              print(
                "Bordereaux stream closed",
              ); // Ajout pour suivre la fermeture
            },
          );
    } catch (e) {
      _errorMessage = "Erreur lors du chargement des bordereaux : $e";
      _isLoading = false;
      notifyListeners();
      print("Error in loadBordereaux: $e"); // Ajout
    }
  }

  Future<void> loadAllBordereaux() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      _bordereauService.getAllBordereauxStream().listen(
        (bordereauList) {
          _bordereaux = bordereauList;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = "Erreur lors du chargement : $error";
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = "Erreur inattendue : $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter un bordereau
  Future<void> addBordereau(
    BordereauModel bordereau,
    BuildContext context,
  ) async {
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.uid;

      if (currentUserId != bordereau.commercialId) {
        throw Exception(
          "Un commercial ne peut ajouter un bordereau que pour lui-même.",
        );
      }
      await _bordereauService.addBordereau(bordereau);
      _bordereaux.add(bordereau);
      notifyListeners();
      print("Bordereau added: ${bordereau.id}"); // Ajout
    } catch (e) {
      _errorMessage = "Erreur lors de l'ajout du bordereau : $e";
      notifyListeners();
      _showErrorSnackbar(context, _errorMessage!);
      rethrow;
    }
  }

  // Mettre à jour un bordereau
  Future<void> updateBordereau(
    BordereauModel bordereau,
    BuildContext context,
  ) async {
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final currentUserUid = authProvider.user?.uid;
      final existingBordereau = await _bordereauService.getBordereauById(
        bordereau.id,
      );

      if (existingBordereau == null ||
          existingBordereau.commercialId != currentUserUid) {
        throw Exception("Vous n'êtes pas autorisé à modifier ce bordereau.");
      }
      await _bordereauService.updateBordereau(bordereau);
      final index = _bordereaux.indexWhere((b) => b.id == bordereau.id);
      if (index != -1) {
        _bordereaux[index] = bordereau;
        notifyListeners();
        print("Bordereau updated: ${bordereau.id}"); // Ajout
      }
    } catch (e) {
      _errorMessage = "Erreur lors de la mise à jour du bordereau : $e";
      notifyListeners();
      _showErrorSnackbar(context, _errorMessage!);
      rethrow;
    }
  }

  // Supprimer un bordereau
  Future<void> deleteBordereau(String bordereauId, BuildContext context) async {
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final currentUserUid = authProvider.user?.uid;
      final bordereauToDelete = await _bordereauService.getBordereauById(
        bordereauId,
      );

      if (bordereauToDelete == null ||
          bordereauToDelete.commercialId != currentUserUid) {
        throw Exception("Vous n'êtes pas autorisé à supprimer ce bordereau.");
      }
      await _bordereauService.deleteBordereau(bordereauId);
      _bordereaux.removeWhere((b) => b.id == bordereauId);
      notifyListeners();
      print("Bordereau deleted: $bordereauId"); // Ajout
    } catch (e) {
      _errorMessage = "Erreur lors de la suppression du bordereau : $e";
      notifyListeners();
      _showErrorSnackbar(context, _errorMessage!);
      rethrow;
    }
  }

  // Soumettre un bordereau
  Future<void> submitBordereau(String bordereauId, BuildContext context) async {
    try {
      await _bordereauService.submitBordereau(bordereauId);
      final index = _bordereaux.indexWhere((b) => b.id == bordereauId);
      if (index != -1) {
        _bordereaux[index] = _bordereaux[index].copyWith(
          status: BordereauModel.statusSubmitted,
        );
        notifyListeners();
        print("Bordereau submitted: $bordereauId"); // Ajout
      }
    } catch (e) {
      _errorMessage = "Erreur lors de la soumission du bordereau : $e";
      notifyListeners();
      _showErrorSnackbar(context, _errorMessage!);
      rethrow;
    }
  }

  // Valider un bordereau
  Future<void> validateBordereau(
    String bordereauId,
    BuildContext context,
  ) async {
    try {
      await _bordereauService.validateBordereau(bordereauId);
      final index = _bordereaux.indexWhere((b) => b.id == bordereauId);
      if (index != -1) {
        _bordereaux[index] = _bordereaux[index].copyWith(
          status: BordereauModel.statusValidated,
        );
        notifyListeners();
        print("Bordereau validated: $bordereauId"); // Ajout
      }
    } catch (e) {
      _errorMessage = "Erreur lors de la validation du bordereau : $e";
      notifyListeners();
      _showErrorSnackbar(context, _errorMessage!);
      rethrow;
    }
  }

  // Rejeter un bordereau
  Future<void> rejectBordereau(
    String bordereauId,
    String commentaire,
    BuildContext context,
  ) async {
    try {
      await _bordereauService.rejectBordereau(bordereauId, commentaire);
      final index = _bordereaux.indexWhere((b) => b.id == bordereauId);
      if (index != -1) {
        _bordereaux[index] = _bordereaux[index].copyWith(
          status: BordereauModel.statusRejected,
          commentaire: commentaire,
        );
        notifyListeners();
        print("Bordereau rejected: $bordereauId"); // Ajout
      }
    } catch (e) {
      const errorMessage = "Erreur lors du rejet du bordereau : erreur";
      _showErrorSnackbar(context, errorMessage);
      rethrow;
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
