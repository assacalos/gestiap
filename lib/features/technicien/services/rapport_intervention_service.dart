import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/technicien/data/models/rapport_intervention_model.dart';
// Assurez-vous du chemin

class RapportInterventionService {
  final CollectionReference _rapportsCollection = FirebaseFirestore.instance
      .collection('rapports_intervention');

  Future<void> addRapportIntervention(RapportInterventionModel rapport) async {
    try {
      await _rapportsCollection.doc(rapport.id).set(rapport.toMap());
    } catch (e) {
      print("Erreur lors de l'ajout du rapport d'intervention : $e");
      rethrow;
    }
  }

  Future<List<RapportInterventionModel>> getAllRapportsIntervention() async {
    try {
      final QuerySnapshot querySnapshot = await _rapportsCollection.get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return RapportInterventionModel.fromMap(data);
      }).toList();
    } catch (e) {
      print("Erreur lors de la récupération des rapports d'intervention : $e");
      rethrow;
    }
  }

  Future<RapportInterventionModel?> getRapportInterventionById(
    String id,
  ) async {
    try {
      final DocumentSnapshot documentSnapshot =
          await _rapportsCollection.doc(id).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return RapportInterventionModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print(
        "Erreur lors de la récupération du rapport d'intervention par ID: $e",
      );
      rethrow;
    }
  }

  Future<void> updateRapportIntervention(
    RapportInterventionModel rapport,
  ) async {
    try {
      await _rapportsCollection.doc(rapport.id).update(rapport.toMap());
    } catch (e) {
      print("Erreur lors de la mise à jour du rapport d'intervention : $e");
      rethrow;
    }
  }

  Future<void> deleteRapportIntervention(String id) async {
    try {
      await _rapportsCollection.doc(id).delete();
    } catch (e) {
      print("Erreur lors de la suppression du rapport d'intervention : $e");
      rethrow;
    }
  }
}
