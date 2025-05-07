import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/core/constants/app_constants.dart'; // Assurez-vous que ce fichier existe
import 'package:gestiap/features/commercial/data/models/client_model.dart'; // Assurez-vous que ce fichier existe

class ClientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName =
      AppConstants
          .clients; // Utilisez la constante pour le nom de la collection

  // Méthode pour ajouter un client à Firestore
  Future<void> addClient(Client client) async {
    try {
      // Ajoute un nouveau document à la collection, et Firestore génère l'ID
      DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(client.toMap());
      // Mettre à jour l'ID du client avec l'ID généré par Firestore.
      client.id = docRef.id;
      await docRef.update({
        'id': docRef.id,
      }); // Enregistre l'ID dans le document
    } catch (error) {
      // Log l'erreur
      print("Erreur lors de l'ajout du client : $error");
      rethrow; // Relance l'erreur pour que le provider puisse la gérer
    }
  }

  // Méthode pour récupérer un client par son ID
  Future<Client> getClientsById(String clientId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection(_collectionName).doc(clientId).get();
      if (!snapshot.exists) {
        throw Exception("Client non trouvé pour l'ID : $clientId");
      }
      // Utilise le constructeur fromMap et passe l'ID du document.
      return Client.fromMap(
        snapshot.data() as Map<String, dynamic>,
        snapshot.id,
      );
    } catch (error) {
      print("Erreur lors de la récupération du client : $error");
      rethrow;
    }
  }

  // Méthode pour mettre à jour un client dans Firestore
  Future<void> updateClient(Client client) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(client.id)
          .update(client.toMap());
    } catch (error) {
      print("Erreur lors de la mise à jour du client : $error");
      rethrow;
    }
  }

  // Méthode pour supprimer un client de Firestore
  Future<void> deleteClient(String clientId) async {
    try {
      await _firestore.collection(_collectionName).doc(clientId).delete();
    } catch (error) {
      print("Erreur lors de la suppression du client : $error");
      rethrow;
    }
  }

  // Méthode pour récupérer tous les clients d'un commercial (optionnel, selon les besoins)
  Stream<List<Client>> getClientsByCommercialId(String commercialId) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('commercialId', isEqualTo: commercialId)
          .snapshots() // Retourne un Stream de QuerySnapshot
          .map((QuerySnapshot snapshot) {
            // Convertit chaque QuerySnapshot en une liste de Client
            return snapshot.docs.map((DocumentSnapshot doc) {
              // Important : Passe l'ID du document à partir du DocumentSnapshot
              return Client.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            }).toList();
          });
    } catch (error) {
      print(
        "Erreur lors de la récupération des clients du commercial : $error",
      );
      // En cas d'erreur, retourne un Stream qui émet une erreur.
      return Stream.value(List.empty()); // or  return Stream.error(error);
    }
  }

  // Méthode pour récupérer tous les clients depuis Firestore
  Stream<List<Client>> getClients() {
    try {
      return _firestore.collection(_collectionName).snapshots().map((
        QuerySnapshot snapshot,
      ) {
        return snapshot.docs.map((DocumentSnapshot doc) {
          return Client.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      // Log the error
      print("Error fetching clients: $e");
      // Return an empty stream or a stream with the error
      return Stream.value([]); // Or return Stream.error(e);
    }
  }
}
