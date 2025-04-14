import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// MODEL : bordereau_model.dart
class BordereauModel {
  final String id;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final String clientContact;
  final String clientAdresse;
  final DateTime createdAt; // Champ ajouté ici
  final String devisId;
  final DateTime dateLivraison;
  final String etatLivraison;
  final String delaiGarantie;
  final String intitule;
  String status;
  final List<ArticleLivraison> articles;

  // Définition des constantes statiques pour les statuts
  static const String statusDraft = 'Brouillon';
  static const String statusSubmitted = 'Soumis';
  static const String statusValidated = 'validé';
  static const String statusRejected = 'Rejeté';
  static const String statusPendingValidation =
      'En attente de validation'; // Nouveau statut

  BordereauModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.clientContact,
    required this.clientAdresse,
    required this.devisId,
    required this.createdAt,
    required this.dateLivraison,
    required this.etatLivraison,
    required this.delaiGarantie,
    required this.articles,
    required this.intitule,
    this.status = statusSubmitted,
  });
  BordereauModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? clientEmail,
    String? clientContact,
    String? clientAdresse,
    DateTime? createdAt,
    String? devisId,
    DateTime? dateLivraison,
    String? etatLivraison,
    String? delaiGarantie,
    String? intitule,
    String? status,
    List<ArticleLivraison>? articles,
  }) {
    return BordereauModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientContact: clientContact ?? this.clientContact,
      clientAdresse: clientAdresse ?? this.clientAdresse,
      createdAt: createdAt ?? this.createdAt,
      devisId: devisId ?? this.devisId,
      dateLivraison: dateLivraison ?? this.dateLivraison,
      etatLivraison: etatLivraison ?? this.etatLivraison,
      delaiGarantie: delaiGarantie ?? this.delaiGarantie,
      intitule: intitule ?? this.intitule,
      status: status ?? this.status,
      articles: articles ?? this.articles,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientContact': clientContact,
      'clientAdresse': clientAdresse,
      'createdAt': createdAt.toIso8601String(),
      'devisId': devisId,
      'dateLivraison': dateLivraison.toIso8601String(),
      'etatLivraison': etatLivraison,
      'delaiGarantie': delaiGarantie,
      'articles': articles.map((e) => e.toMap()).toList(),
      'intitule': intitule,
      'status': status,
    };
  }

  factory BordereauModel.fromMap(Map<String, dynamic> map) {
    return BordereauModel(
      id: map['id'],
      clientId: map['clientId'],
      clientName: map['clientName'],
      clientEmail: map['clientEmail'],
      clientContact: map['clientContact'],
      clientAdresse: map['clientAdresse'],
      createdAt: DateTime.parse(map['createdAt']),
      devisId: map['devisId'],
      dateLivraison: DateTime.parse(map['dateLivraison']),
      etatLivraison: map['etatLivraison'],
      delaiGarantie: map['delaiGarantie'],
      intitule: map['intitule'],
      status: map['status'],
      articles: List<ArticleLivraison>.from(
        map['articles'].map((x) => ArticleLivraison.fromMap(x)),
      ),
    );
  }

  factory BordereauModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return BordereauModel(
      id: doc.id,
      clientId: data?['clientId'] ?? '',
      clientName: data?['clientName'] ?? '',
      clientEmail: data?['clientEmail'] ?? '',
      clientContact: data?['clientContact'] ?? '',
      clientAdresse: data?['clientAdresse'] ?? '',
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      devisId: data?['devisId'] ?? '',
      dateLivraison:
          (data?['dateLivraison'] as Timestamp?)?.toDate() ?? DateTime.now(),
      etatLivraison: data?['etatLivraison'] ?? '',
      delaiGarantie: data?['delaiGarantie'] ?? '',
      intitule: data?['intitule'] ?? '',
      status: data?['status'] ?? 'En attente',
      articles:
          (data?['articles'] as List<dynamic>?)
              ?.map(
                (item) =>
                    ArticleLivraison.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class ArticleLivraison {
  final int ref;
  final String description;
  final int quantity;

  ArticleLivraison({
    required this.ref,
    required this.description,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {'ref': ref, 'description': description, 'quantity': quantity};
  }

  factory ArticleLivraison.fromMap(Map<String, dynamic> map) {
    return ArticleLivraison(
      ref: map['ref'],
      description: map['description'],
      quantity: map['quantity'],
    );
  }
}
