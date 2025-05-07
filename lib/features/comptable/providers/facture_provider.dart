import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestiap/features/comptable/data/models/facture_model.dart';

class InvoiceProvider extends ChangeNotifier {
  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;

  List<InvoiceModel> get invoices => _invoices;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'invoices';

  Future<void> loadInvoices() async {
    _isLoading = true;
    notifyListeners();
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(_collection).get();
      _invoices =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return InvoiceModel.fromJson(data)..id = doc.id;
          }).toList();
    } catch (error) {
      print('Erreur lors du chargement des factures : $error');
      // Gérer l'erreur ici (afficher un message, etc.)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addInvoice(InvoiceModel invoice) async {
    try {
      final DocumentReference<Map<String, dynamic>> docRef = await _firestore
          .collection(_collection)
          .add(invoice.toJson());
      invoice.id = docRef.id;
      _invoices.add(invoice);
      notifyListeners();
    } catch (error) {
      print('Erreur lors de l\'ajout de la facture : $error');
      // Gérer l'erreur ici
    }
  }

  Future<void> updateInvoice(InvoiceModel invoice) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(invoice.id)
          .update(invoice.toJson());
      final index = _invoices.indexWhere((inv) => inv.id == invoice.id);
      if (index != -1) {
        _invoices[index] = invoice;
        notifyListeners();
      }
    } catch (error) {
      print('Erreur lors de la mise à jour de la facture : $error');
      // Gérer l'erreur ici
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _firestore.collection(_collection).doc(invoiceId).delete();
      _invoices.removeWhere((inv) => inv.id == invoiceId);
      notifyListeners();
    } catch (error) {
      print('Erreur lors de la suppression de la facture : $error');
      // Gérer l'erreur ici
    }
  }

  Future<void> submitInvoice(String invoiceId) async {
    try {
      await _firestore.collection(_collection).doc(invoiceId).update({
        'status': InvoiceModel.statusSubmitted,
      });
      final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
      if (index != -1) {
        _invoices[index] = _invoices[index].copyWith(
          status: InvoiceModel.statusSubmitted,
        );
        notifyListeners();
      }
    } catch (error) {
      print('Erreur lors de la soumission de la facture : $error');
      // Gérer l'erreur ici
    }
  }

  Future<void> validateInvoice(String invoiceId) async {
    try {
      await _firestore.collection(_collection).doc(invoiceId).update({
        'status': InvoiceModel.statusValidated,
      });
      final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
      if (index != -1) {
        _invoices[index] = _invoices[index].copyWith(
          status: InvoiceModel.statusValidated,
        );
        notifyListeners();
      }
    } catch (error) {
      print('Erreur lors de la validation de la facture : $error');
      // Gérer l'erreur ici
    }
  }

  Future<void> rejectInvoice(String invoiceId, String reason) async {
    try {
      await _firestore.collection(_collection).doc(invoiceId).update({
        'status': InvoiceModel.statusRejected,
        'commentaireRejet': reason,
      });
      final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
      if (index != -1) {
        _invoices[index] = _invoices[index].copyWith(
          status: InvoiceModel.statusRejected,
          commentaireRejet: reason,
        );
        notifyListeners();
      }
    } catch (error) {
      print('Erreur lors du rejet de la facture : $error');
      // Gérer l'erreur ici
    }
  }

  Future<void> generateInvoicePdf(InvoiceModel invoice) async {
    // Implémentez la logique pour générer le PDF de la facture ici
    // Vous pouvez utiliser une bibliothèque comme pdf ou pdf_flutter
    // pour créer le PDF et l'enregistrer ou l'afficher.
  }
}
