import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/comptable/data/models/impot_taxes_model.dart'; // Assurez-vous que le chemin est correct

class ImpotTaxeService {
  final CollectionReference _impotsTaxesCollection = FirebaseFirestore.instance
      .collection('impots_taxes');

  // Ajouter un impôt/taxe
  Future<void> addImpotTaxe(ImpotTaxeModel impotTaxe) async {
    try {
      await _impotsTaxesCollection.doc(impotTaxe.id).set(impotTaxe.toMap());
    } catch (e) {
      // Gérer les erreurs d'ajout (par exemple, log, afficher un message)
      print("Erreur lors de l'ajout de l'impôt/taxe : $e");
      rethrow; // Relancer l'erreur pour que le provider puisse la gérer
    }
  }

  // Récupérer tous les impôts/taxes
  Future<List<ImpotTaxeModel>> getAllImpotsTaxes() async {
    try {
      final QuerySnapshot querySnapshot = await _impotsTaxesCollection.get();
      return querySnapshot.docs.map((doc) {
        //Utilisation de .data()
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ImpotTaxeModel.fromMap(data);
      }).toList();
    } catch (e) {
      print("Erreur lors de la récupération des impôts/taxes : $e");
      rethrow;
    }
  }

  // Mettre à jour un impôt/taxe
  Future<void> updateImpotTaxe(ImpotTaxeModel impotTaxe) async {
    try {
      await _impotsTaxesCollection.doc(impotTaxe.id).update(impotTaxe.toMap());
    } catch (e) {
      print("Erreur lors de la mise à jour de l'impôt/taxe : $e");
      rethrow;
    }
  }

  // Supprimer un impôt/taxe
  Future<void> deleteImpotTaxe(String id) async {
    try {
      await _impotsTaxesCollection.doc(id).delete();
    } catch (e) {
      print("Erreur lors de la suppression de l'impôt/taxe : $e");
      rethrow;
    }
  }

  // Récupérer un impôt/taxe par ID (optionnel, utile pour les détails)
  Future<ImpotTaxeModel?> getImpotTaxeById(String id) async {
    try {
      final DocumentSnapshot documentSnapshot =
          await _impotsTaxesCollection.doc(id).get();
      if (documentSnapshot.exists) {
        //Utilisation de .data()
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return ImpotTaxeModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération de l'impôt/taxe par ID : $e");
      rethrow;
    }
  }
}
