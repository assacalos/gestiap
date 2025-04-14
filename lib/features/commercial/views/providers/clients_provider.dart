import 'package:flutter/material.dart';
import 'package:gestiap/core/services/client_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/core/constants/app_constants.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';

class ClientProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Client> _clients = [];

  final ClientService _clientService = ClientService();

  List<Client> get clients => _clients;

  // Charger les clients depuis Firestore
  void loadClients() {
    _clientService.getClients().listen((clientsData) {
      _clients = clientsData;
      notifyListeners();
    });
  }

  // Exemple de méthode dans CommercialRepository
  Future<List<Client>> getClients() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('clients').get();
      List<Client> clients =
          querySnapshot.docs.map((doc) {
            return Client.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
      return clients;
    } catch (e) {
      print('Erreur lors de la récupération des clients: $e');
      return []; // Retourne une liste vide en cas d'erreur
    }
  }

  // Ajouter un client
  Future<void> addClient(Client client) async {
    await _clientService.addClient(client);
  }

  // Modifier un client
  Future<void> updateClient(Client client) async {
    await _clientService.updateClient(client);
  }

  // Supprimer un client
  Future<void> deleteClient(String id) async {
    await _clientService.deleteClient(id);
  }
}
