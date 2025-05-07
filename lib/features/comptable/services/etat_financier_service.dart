import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/comptable/data/models/etat_financier_model.dart';

class EtatFinancierService {
  final CollectionReference _etatsFinanciersCollection = FirebaseFirestore
      .instance
      .collection('etats_financiers');

  Future<void> addEtatFinancier(EtatFinancierModel etatFinancier) async {
    try {
      await _etatsFinanciersCollection
          .doc(etatFinancier.id)
          .set(etatFinancier.toMap());
    } catch (e) {
      print("Erreur lors de l'ajout de l'état financier : $e");
      rethrow;
    }
  }

  Future<List<EtatFinancierModel>> getAllEtatsFinanciers() async {
    try {
      final QuerySnapshot querySnapshot =
          await _etatsFinanciersCollection.get();
      return querySnapshot.docs.map((doc) {
        // IMPORTANT : Traiter les données nullables et dynamiques correctement.
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return EtatFinancierModel.fromMap(data);
      }).toList();
    } catch (e) {
      print("Erreur lors de la récupération des états financiers : $e");
      rethrow;
    }
  }

  Future<void> updateEtatFinancier(EtatFinancierModel etatFinancier) async {
    try {
      await _etatsFinanciersCollection
          .doc(etatFinancier.id)
          .update(etatFinancier.toMap());
    } catch (e) {
      print("Erreur lors de la mise à jour de l'état financier : $e");
      rethrow;
    }
  }

  Future<void> deleteEtatFinancier(String id) async {
    try {
      await _etatsFinanciersCollection.doc(id).delete();
    } catch (e) {
      print("Erreur lors de la suppression de l'état financier : $e");
      rethrow;
    }
  }

  Future<EtatFinancierModel?> getEtatFinancierById(String id) async {
    try {
      final DocumentSnapshot documentSnapshot =
          await _etatsFinanciersCollection.doc(id).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return EtatFinancierModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération de l'état financier par ID: $e");
      rethrow;
    }
  }
}
