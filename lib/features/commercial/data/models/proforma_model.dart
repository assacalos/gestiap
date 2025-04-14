import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class QuoteItem {
  String description;
  int quantity;
  double unitPrice;
  int ref;

  QuoteItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.ref,
  });

  Map<String, dynamic> toMap() => {
    'description': description,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'ref': ref,
  };

  factory QuoteItem.fromMap(Map<String, dynamic> map) => QuoteItem(
    description: map['description'],
    quantity: map['quantity'],
    unitPrice: (map['unitPrice'] ?? 0).toDouble(),
    ref: map['ref'] ?? 0,
  );
}

class QuoteModel {
  String id;
  String clientId;
  String clientName;
  String description;
  double amount;
  DateTime createdAt;
  String status;
  List<QuoteItem> items;
  double remise;
  int ref;
  final double totalHT;
  final double totalTTC;

  // Définition des constantes statiques pour les statuts
  static const String statusDraft = 'Brouillon';
  static const String statusSubmitted = 'Soumis';
  static const String statusValidated = 'validé';
  static const String statusRejected = 'Rejeté';
  static const String statusPendingValidation =
      'En attente de validation'; // Nouveau statut

  QuoteModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.description,
    required this.amount,
    required this.createdAt,
    this.status = statusSubmitted,
    required this.items,
    required this.remise,
    required this.ref,
    required this.totalHT,
    required this.totalTTC,
  });

  QuoteModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? description,
    double? amount,
    double? remise,
    DateTime? createdAt,
    String? status,
    List<QuoteItem>? items,
    int? ref,
    double? totalHT,
    double? totalTTC,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      remise: remise ?? this.remise,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      items: items ?? this.items,
      ref: ref ?? this.ref,
      totalHT: totalHT ?? this.totalHT,
      totalTTC: totalTTC ?? this.totalTTC,
    );
  }

  factory QuoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return QuoteModel(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      createdAt:
          (() {
            final rawDate = data['createdAt'];
            if (rawDate is Timestamp) {
              return rawDate.toDate();
            } else if (rawDate is String) {
              try {
                return DateTime.parse(rawDate);
              } catch (_) {
                return DateTime.now(); // fallback si parsing échoue
              }
            } else {
              return DateTime.now(); // fallback si null ou autre type
            }
          })(),

      status: data['status'] ?? '',
      remise: (data['remise'] ?? 0).toDouble(),
      ref: data['ref'] ?? 0,
      totalHT: (data['totalHT'] ?? 0).toDouble(),
      totalTTC: (data['totalTTC'] ?? 0).toDouble(),
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => QuoteItem.fromMap(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'description': description,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'ref': ref,
      'remise': remise,
      'items': items.map((item) => item.toMap()).toList(),
      'totalHT': totalHT,
      'totalTTC': totalTTC,
    };
  }

  double get totalHTT =>
      items.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

  double get totalTTCC => totalHT - remise;
}
