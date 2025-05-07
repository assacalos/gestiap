import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/technicien/data/models/interventions_model.dart';

class InterventionService {
  final CollectionReference _interventionsCollection = FirebaseFirestore
      .instance
      .collection('interventions');

  Future<void> addIntervention(InterventionModel intervention) async {
    try {
      await _interventionsCollection
          .doc(intervention.id)
          .set(intervention.toMap());
    } catch (e) {
      print("Erreur lors de l'ajout de l'intervention : $e");
      rethrow;
    }
  }

  Future<List<InterventionModel>> getAllInterventions() async {
    try {
      final QuerySnapshot querySnapshot = await _interventionsCollection.get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return InterventionModel.fromMap(data);
      }).toList();
    } catch (e) {
      print("Erreur lors de la récupération des interventions : $e");
      rethrow;
    }
  }

  Future<InterventionModel?> getInterventionById(String id) async {
    try {
      final DocumentSnapshot documentSnapshot =
          await _interventionsCollection.doc(id).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return InterventionModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération de l'intervention par ID: $e");
      rethrow;
    }
  }

  Future<void> updateIntervention(InterventionModel intervention) async {
    try {
      await _interventionsCollection
          .doc(intervention.id)
          .update(intervention.toMap());
    } catch (e) {
      print("Erreur lors de la mise à jour de l'intervention : $e");
      rethrow;
    }
  }

  Future<void> deleteIntervention(String id) async {
    try {
      await _interventionsCollection.doc(id).delete();
    } catch (e) {
      print("Erreur lors de la suppression de l'intervention : $e");
      rethrow;
    }
  }
}
