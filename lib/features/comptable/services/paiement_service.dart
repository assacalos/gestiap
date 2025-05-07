import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/comptable/data/models/paiement_model.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'payments';

  Future<List<PaymentModel>> getPaymentsForCharge(String chargeId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore
              .collection(_collection)
              .where('chargeId', isEqualTo: chargeId)
              .orderBy('paymentDate', descending: true)
              .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PaymentModel.fromJson(data)..id = doc.id;
      }).toList();
    } catch (error) {
      print(
        'Erreur lors de la récupération des paiements pour la charge $chargeId : $error',
      );
      return [];
    }
  }

  Future<PaymentModel?> getPayment(String paymentId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection(_collection).doc(paymentId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return PaymentModel.fromJson(data)..id = doc.id;
      }
      return null;
    } catch (error) {
      print('Erreur lors de la récupération du paiement $paymentId : $error');
      return null;
    }
  }

  Future<void> addPayment(PaymentModel payment) async {
    try {
      await _firestore.collection(_collection).add(payment.toJson());
    } catch (error) {
      print('Erreur lors de l\'ajout du paiement : $error');
      rethrow; // Propager l'erreur pour être gérée par le provider
    }
  }

  Future<void> updatePayment(PaymentModel payment) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(payment.id)
          .update(payment.toJson());
    } catch (error) {
      print('Erreur lors de la mise à jour du paiement ${payment.id} : $error');
      rethrow;
    }
  }

  Future<void> deletePayment(String paymentId) async {
    try {
      await _firestore.collection(_collection).doc(paymentId).delete();
    } catch (error) {
      print('Erreur lors de la suppression du paiement $paymentId : $error');
      rethrow;
    }
  }
}
