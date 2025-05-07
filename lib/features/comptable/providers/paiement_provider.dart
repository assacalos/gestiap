import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/data/models/paiement_model.dart';
import 'package:gestiap/features/comptable/services/paiement_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPaymentsForCharge(String employeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _payments = await _paymentService.getPaymentsForCharge(employeId);
    } catch (error) {
      _errorMessage = 'Erreur lors du chargement des paiements : $error';
      print(_errorMessage);
      _payments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PaymentModel?> getPayment(String paymentId) async {
    return _paymentService.getPayment(paymentId);
  }

  Future<void> addPayment(PaymentModel payment) async {
    try {
      await _paymentService.addPayment(payment);
      // Après l'ajout, potentiellement recharger la liste pour refléter le changement
      await loadPaymentsForCharge(payment.employeId);
    } catch (error) {
      _errorMessage = 'Erreur lors de l\'ajout du paiement : $error';
      print(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePayment(PaymentModel payment) async {
    try {
      await _paymentService.updatePayment(payment);
      // Après la mise à jour, recharger la liste
      await loadPaymentsForCharge(payment.employeId);
    } catch (error) {
      _errorMessage = 'Erreur lors de la mise à jour du paiement : $error';
      print(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePayment(String paymentId, String employeId) async {
    try {
      await _paymentService.deletePayment(paymentId);
      // Après la suppression, recharger la liste
      await loadPaymentsForCharge(employeId);
    } catch (error) {
      _errorMessage = 'Erreur lors de la suppression du paiement : $error';
      print(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
}
