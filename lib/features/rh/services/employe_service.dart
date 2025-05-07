import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/rh/data/models/employes_model.dart';

class EmployeService {
  final CollectionReference _employesCollection = FirebaseFirestore.instance
      .collection('employes');

  Future<void> addEmploye(EmployeModel employe) async {
    try {
      await _employesCollection.doc(employe.id).set(employe.toMap());
    } catch (e) {
      print("Erreur lors de l'ajout de l'employé : $e");
      rethrow;
    }
  }

  Future<List<EmployeModel>> getAllEmployes() async {
    try {
      final QuerySnapshot querySnapshot = await _employesCollection.get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return EmployeModel.fromMap(data);
      }).toList();
    } catch (e) {
      print("Erreur lors de la récupération des employés : $e");
      rethrow;
    }
  }

  Future<EmployeModel?> getEmployeById(String id) async {
    try {
      final DocumentSnapshot documentSnapshot =
          await _employesCollection.doc(id).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return EmployeModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération de l'employé par ID: $e");
      rethrow;
    }
  }

  Future<void> updateEmploye(EmployeModel employe) async {
    try {
      await _employesCollection.doc(employe.id).update(employe.toMap());
    } catch (e) {
      print("Erreur lors de la mise à jour de l'employé : $e");
      rethrow;
    }
  }

  Future<void> deleteEmploye(String id) async {
    try {
      await _employesCollection.doc(id).delete();
    } catch (e) {
      print("Erreur lors de la suppression de l'employé : $e");
      rethrow;
    }
  }
}
