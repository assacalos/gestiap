import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';

class ClientService {
  final CollectionReference clientsCollection = FirebaseFirestore.instance
      .collection('clients');

  // Ajouter un client
  Future<void> addClient(Client client) async {
    DocumentReference docRef = await clientsCollection.add(client.toMap());
    await docRef.update({'id': docRef.id}); // Mettre à jour l'ID
  }

  // Récupérer tous les clients
  Stream<List<Client>> getClients() {
    return clientsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => Client.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }

  // Modifier un client
  Future<void> updateClient(Client client) async {
    await clientsCollection.doc(client.id).update(client.toMap());
  }

  // Supprimer un client
  Future<void> deleteClient(String clientId) async {
    await clientsCollection.doc(clientId).delete();
  }
}
