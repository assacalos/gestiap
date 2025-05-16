import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/core/services/auth_service.dart';
import 'package:gestiap/features/commercial/services/clients/client_service.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/services/proformas/proforma_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gestiap/providers/auth_provider.dart';

class ClientProvider with ChangeNotifier {
  final ClientService _clientService = ClientService();
  List<Client> _clients = [];
  bool _isLoading = true;
  String? _errorMessage;
  final AuthService _authService = AuthService();

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ClientProvider() {
    loadClientsByRole();
  }

  Future<void> loadClients() async {
    _loadClients();
  }

  Future<void> loadClientsByRole() async {
    final role = await _authService.getUserRole();
    if (role == 'patron') {
      await loadAllClients();
    } else {
      await loadClients(); // pour commercial
    }
  }

  Future<void> _loadClients() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) {
        _errorMessage = "Utilisateur non connecté.";
        _isLoading = false;
        notifyListeners();
        return;
      }
      _clientService
          .getClientsStreamByCommercialId(currentUserId)
          .listen(
            (clientList) {
              _clients = clientList;
              _isLoading = false;
              notifyListeners();
            },
            onError: (error) {
              _errorMessage = "Erreur lors du chargement des clients: $error";
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      _errorMessage = "Failed to load clients: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllClients() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      _clientService.getAllClientsStream().listen(
        (clientList) {
          _clients = clientList;
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

  Future<void> addClient(Client client) async {
    try {
      final currentUserId = _authService.currentUser?.uid;

      await _clientService.addClient(client);

      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to add client: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateClient(Client client) async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      final existingClient = await _clientService.getClientById(client.id);
      if (existingClient == null) {
        throw Exception("Client non trouvé.");
      }

      await _clientService.updateClient(client);
      final index = _clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        _clients[index] = client;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to update client: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      final currentUserId = _authService.currentUser?.uid;

      final clientToDelete = await _clientService.getClientById(clientId);
      if (clientToDelete == null) {
        throw Exception("Client non trouvé.");
      }
      await _clientService.deleteClient(clientId);
      _clients.removeWhere((c) => c.id == clientId);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to delete client: $e";
      notifyListeners();
      rethrow;
    }
  }

  // Soumettre un client
  Future<void> submitClient(String clientId) async {
    try {
      final client = await _clientService.getClientById(clientId);
      if (client == null) {
        throw Exception("Client non trouvé.");
      }
      final updatedClient = client.copyWith(status: 'Soumis');
      await _clientService.updateClient(updatedClient);
      final index = _clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        _clients[index] = updatedClient;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to submit client: $e";
      notifyListeners();
      rethrow;
    }
  }

  // Valider un client
  Future<void> validateClient(String clientId) async {
    try {
      final client = await _clientService.getClientById(clientId);
      if (client == null) {
        throw Exception("Client non trouvé.");
      }
      final updatedClient = client.copyWith(status: 'Validé');
      await _clientService.updateClient(updatedClient);

      final index = _clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        _clients[index] = updatedClient;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to validate client: $e";
      notifyListeners();
      rethrow;
    }
  }

  // Rejeter un client
  Future<void> rejectClient(String clientId, String rejectionReason) async {
    try {
      final client = await _clientService.getClientById(clientId);
      if (client == null) {
        throw Exception("Client non trouvé.");
      }
      final updatedClient = client.copyWith(
        status: 'Rejeté',
        commentaire: rejectionReason,
      );
      await _clientService.updateClient(updatedClient);
      final index = _clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        _clients[index] = updatedClient;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to reject client: $e";
      notifyListeners();
      rethrow;
    }
  }
}
