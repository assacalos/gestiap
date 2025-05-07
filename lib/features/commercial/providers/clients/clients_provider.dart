import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/core/constants/app_constants.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/providers/auth_provider.dart';
import 'package:gestiap/features/commercial/services/clients/client_service.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';

class ClientProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ClientService _clientService = ClientService(); // Utilisez le service

  List<Client> _clients = [];

  List<Client> get clients => _clients;

  ClientProvider();

  // Charger les clients depuis Firestore en utilisant le service
  void loadClients() {
    _clientService.getClients().listen((clientsData) {
      _clients = clientsData;
      notifyListeners();
    });
  }

  Future<void> getClients() async {
    try {
      // Écouter le stream et mettre à jour la liste lorsqu'il émet une valeur.
      _clientService.getClients().listen((clientList) {
        _clients = clientList;
        notifyListeners();
      });
    } catch (error) {
      print("Error fetching clients: $error");
      rethrow;
    }
  }

  // Ajouter un client en utilisant le service
  Future<void> addClient(Client client, BuildContext context) async {
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.uid;

      if (currentUserId == null) {
        throw Exception("Utilisateur non connecté.");
      }

      // IMPORTANT : Vérifier que le commercialId du client correspond à l'utilisateur connecté
      if (client.commercialId != currentUserId) {
        throw Exception(
          "Un commercial ne peut ajouter un client qu'à lui-même.",
        );
      }

      await _clientService.addClient(client);
      _clients.add(client);
      notifyListeners();
    } catch (error) {
      // Gérer l'erreur (afficher un SnackBar, journaliser, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout du client: $error'),
          duration: Duration(seconds: 5),
        ),
      );
      rethrow;
    }
  }

  // Modifier un client en utilisant le service
  Future<void> updateClient(Client client, BuildContext context) async {
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.uid;

      if (currentUserId == null) {
        throw Exception("Utilisateur non connecté.");
      }

      // Récupérer le client actuel depuis la base de données pour vérifier le commercialId
      final existingClient = await _clientService.getClientsById(
        client.id,
      ); // Ajoute cette méthode dans ClientService
      if (existingClient.commercialId != currentUserId) {
        throw Exception(
          "Un commercial ne peut modifier que ses propres clients.",
        );
      }

      await _clientService.updateClient(client);
      final index = _clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        _clients[index] = client;
        notifyListeners();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la modification du client: $error'),
          duration: Duration(seconds: 5),
        ),
      );
      rethrow;
    }
  }

  // Supprimer un client en utilisant le service
  Future<void> deleteClient(String clientId, BuildContext context) async {
    // Add context
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.uid;

      if (currentUserId == null) {
        throw Exception("Utilisateur non connecté.");
      }
      final clientToDelete = await _clientService.getClientsById(
        clientId,
      ); //Implement this in service
      if (clientToDelete.commercialId != currentUserId) {
        throw Exception(
          "Un commercial ne peut supprimer que ses propres clients.",
        );
      }

      await _clientService.deleteClient(clientId);
      _clients.removeWhere((client) => client.id == clientId);
      notifyListeners();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression du client: $error'),
          duration: Duration(seconds: 5),
        ),
      );
      rethrow;
    }
  }

  // Obtenir tous les clients
  List<Client> getAllClients() {
    return _clients;
  }
}
