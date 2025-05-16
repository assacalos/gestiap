import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/core/constants/app_constants.dart'; // Assurez-vous que ce fichier existe
import 'package:gestiap/features/commercial/data/models/client_model.dart'; // Assurez-vous que ce fichier existe

class ClientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName =
      'clients'; // Utilisez une constante pour le nom de la collection

  // Récupérer un client par ID
  Future<Client?> getClientById(String clientId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collectionName).doc(clientId).get();
      if (doc.exists) {
        return Client.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        ); // Utilise le constructeur fromMap et passe l'ID du document.
      } else {
        return null; // Retourne null si le document n'existe pas
      }
    } catch (e) {
      print("Erreur lors de la récupération du client : $e");
      rethrow;
    }
  }

  Stream<List<Client>> getAllClientsStream() {
    return _firestore
        .collection(_collectionName) // Utilisez _firestore
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => Client.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  ) // Include doc.id
                  .toList(),
        );
  }

  // Ajouter un nouveau client
  Future<void> addClient(Client client) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(client.toMap());
      client.id = docRef.id; // Important : Mettre à jour l'ID du client
      await docRef.update({'id': client.id});
    } catch (e) {
      print("Erreur lors de l'ajout du client : $e");
      rethrow;
    }
  }

  // Mettre à jour un client existant
  Future<void> updateClient(Client client) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(client.id)
          .update(client.toMap());
    } catch (e) {
      print("Erreur lors de la mise à jour du client : $e");
      rethrow;
    }
  }

  // Supprimer un client
  Future<void> deleteClient(String clientId) async {
    try {
      await _firestore.collection(_collectionName).doc(clientId).delete();
    } catch (e) {
      print("Erreur lors de la suppression du client : $e");
      rethrow;
    }
  }

  Future<List<Client>> getClientsByStatus(
    String status, {
    required String commercialId,
  }) async {
    final querySnapshot =
        await _firestore
            .collection(_collectionName)
            .where('status', isEqualTo: status)
            .where('commercialId', isEqualTo: commercialId)
            .get();

    return querySnapshot.docs
        .map(
          (doc) => Client.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  // Récupérer tous les clients
  Stream<List<Client>> getClientsStreamByCommercialId(String commercialId) {
    return _firestore
        .collection(_collectionName)
        .where(
          'commercialId',
          isEqualTo: commercialId,
        ) // Filtrer par commercialId
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    Client.fromMap(doc.data() as Map<String, dynamic>, doc.id),
              )
              .toList();
        });
  }
}

/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';

class ClientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'clients';

  /// Ajoute un nouveau client dans Firestore
  Future<void> addClient(Client client) async {
    final docRef = _firestore.collection(collectionPath).doc();
    final newClient = client.copyWith(id: docRef.id);
    await docRef.set(newClient.toMap());
  }

  /// Met à jour les données d’un client
  Future<void> updateClient(Client client) async {
    if (client.id == null) throw Exception("ID du client manquant");
    await _firestore.collection(collectionPath).doc(client.id).update(client.toMap());
  }

  /// Récupère tous les clients pour un commercial donné
  Future<List<Client>> getClientsByCommercialId(String commercialId) async {
    final querySnapshot = await _firestore
        .collection(collectionPath)
        .where('commercialId', isEqualTo: commercialId)
        .get();

    return querySnapshot.docs
        .map((doc) => Client.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  /// Récupère les clients par statut et commercial
  Future<List<Client>> getClientsByStatus(String status, {required String commercialId}) async {
    final querySnapshot = await _firestore
        .collection(collectionPath)
        .where('status', isEqualTo: status)
        .where('commercialId', isEqualTo: commercialId)
        .get();

    return querySnapshot.docs
        .map((doc) => Client.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  /// Soumet un client (changement de statut)
  Future<void> submitClient(String clientId) async {
    await _firestore.collection(collectionPath).doc(clientId).update({
      'status': Client.statusPendingValidation,
    });
  }

  /// Valide un client
  Future<void> validateClient(String clientId) async {
    await _firestore.collection(collectionPath).doc(clientId).update({
      'status': Client.statusValidated,
    });
  }

  /// Rejette un client
  Future<void> rejectClient(String clientId) async {
    await _firestore.collection(collectionPath).doc(clientId).update({
      'status': Client.statusRejected,
    });
  }
} */
