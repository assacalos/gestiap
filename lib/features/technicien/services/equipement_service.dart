import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/technicien/data/models/equipements_model.dart';

class EquipementService {
  final CollectionReference _equipementsCollection = FirebaseFirestore.instance
      .collection('equipements');

  Future<void> addEquipement(EquipementModel equipement) async {
    try {
      await _equipementsCollection.doc(equipement.id).set(equipement.toMap());
    } catch (e) {
      print("Erreur lors de l'ajout de l'équipement : $e");
      rethrow;
    }
  }

  Future<List<EquipementModel>> getAllEquipements() async {
    try {
      final QuerySnapshot querySnapshot = await _equipementsCollection.get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return EquipementModel.fromMap(data);
      }).toList();
    } catch (e) {
      print("Erreur lors de la récupération des équipements : $e");
      rethrow;
    }
  }

  Future<EquipementModel?> getEquipementById(String id) async {
    try {
      final DocumentSnapshot documentSnapshot =
          await _equipementsCollection.doc(id).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return EquipementModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération de l'équipement par ID: $e");
      rethrow;
    }
  }

  Future<void> updateEquipement(EquipementModel equipement) async {
    try {
      await _equipementsCollection
          .doc(equipement.id)
          .update(equipement.toMap());
    } catch (e) {
      print("Erreur lors de la mise à jour de l'équipement : $e");
      rethrow;
    }
  }

  Future<void> deleteEquipement(String id) async {
    try {
      await _equipementsCollection.doc(id).delete();
    } catch (e) {
      print("Erreur lors de la suppression de l'équipement : $e");
      rethrow;
    }
  }
}
