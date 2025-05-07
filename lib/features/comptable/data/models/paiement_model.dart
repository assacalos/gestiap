import 'package:flutter/material.dart';

class PaymentModel {
  String id;
  String employeId; // ID de la charge associée
  DateTime paymentDate;
  double amount;
  String paymentMethod; // Ex: 'Mobile Money', 'Carte Bancaire', 'Espèces'
  String status; // Ex: 'En attente', 'Réussi', 'Échoué'
  String? transactionId; // ID de la transaction (si applicable)
  String? notes;

  PaymentModel({
    required this.id,
    required this.employeId,
    required this.paymentDate,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.notes,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      employeId: json['employeId'] ?? '',
      paymentDate: (json['paymentDate']).toDate(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? 'En attente',
      transactionId: json['transactionId'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeId': employeId,
      'paymentDate': paymentDate.toUtc(),
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': transactionId,
      'notes': notes,
    };
  }

  // Méthode pour copier l'objet avec des modifications
  PaymentModel copyWith({
    String? id,
    String? employeId,
    DateTime? paymentDate,
    double? amount,
    String? paymentMethod,
    String? status,
    String? transactionId,
    String? notes,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      employeId: employeId ?? this.employeId,
      paymentDate: paymentDate ?? this.paymentDate,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
    );
  }
}
