import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/rh/data/models/conges_model.dart';

class CongeService {
  final CollectionReference _congesCollection = FirebaseFirestore.instance
      .collection('conges');

  Future<void> addConge(CongeModel conge) async {
    try {
      await _congesCollection.doc(conge.id).set(conge.toMap());
    } catch (e) {
      print("Erreur lors de l'ajout du congé : $e");
      rethrow;
    }
  }

  Future<List<CongeModel>> getAllConges() async {
    try {
      final QuerySnapshot querySnapshot = await _congesCollection.get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data =
            doc.data() as Map<String, dynamic>; // Cast doc.data()
        return CongeModel.fromMap(data);
      }).toList();
    } catch (e) {
      print("Erreur lors de la récupération des congés : $e");
      rethrow;
    }
  }

  Future<List<CongeModel>> getCongesByEmployeId(String employeId) async {
    try {
      final QuerySnapshot querySnapshot =
          await _congesCollection
              .where('employeId', isEqualTo: employeId)
              .get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data =
            doc.data() as Map<String, dynamic>; // Cast doc.data()
        return CongeModel.fromMap(data);
      }).toList();
    } catch (e) {
      print("Erreur lors de la récupération des congés par employé : $e");
      rethrow;
    }
  }

  Future<void> updateConge(CongeModel conge) async {
    try {
      await _congesCollection.doc(conge.id).update(conge.toMap());
    } catch (e) {
      print("Erreur lors de la mise à jour du congé : $e");
      rethrow;
    }
  }

  Future<void> deleteConge(String id) async {
    try {
      await _congesCollection.doc(id).delete();
    } catch (e) {
      print("Erreur lors de la suppression du congé : $e");
      rethrow;
    }
  }

  Future<CongeModel?> getCongeById(String id) async {
    try {
      final DocumentSnapshot documentSnapshot =
          await _congesCollection.doc(id).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return CongeModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération du congé par ID: $e");
      rethrow;
    }
  }
}
