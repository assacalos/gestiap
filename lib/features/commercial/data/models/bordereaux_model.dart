import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// MODEL : bordereau_model.dart
class BordereauModel {
  String id;
  final String clientId;
  final String commercialId;
  final String commentaire;
  final String clientName;
  final String clientEmail;
  final String clientContact;
  final String clientAdresse;
  final DateTime createdAt;
  final String devisId;
  final DateTime dateLivraison;
  final String etatLivraison;
  final String delaiGarantie;
  final String intitule;
  String status;
  final List<ArticleLivraison> articles;

  // Définition des constantes statiques pour les statuts
  static const String statusSubmitted = 'Soumis';
  static const String statusValidated =
      'Validé'; // Correction de la faute d'orthographe
  static const String statusRejected = 'Rejeté';
  static const String statusPendingValidation = 'En attente de validation';

  BordereauModel({
    required this.id,
    required this.clientId,
    required this.commercialId,
    required this.commentaire,
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
    String? commercialId,
    String? commentaire,
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
      commercialId: commercialId ?? this.commercialId,
      commentaire: commentaire ?? this.commentaire,
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
      'commercialId': commercialId,
      'commentaire': commentaire,
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
      commercialId: map['commercialId'],
      commentaire: map['commentaire'],
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
        (map['articles'] as List<dynamic>).map(
          (x) => ArticleLivraison.fromMap(x as Map<String, dynamic>),
        ), // Ajout du cast ici
      ),
    );
  }

  factory BordereauModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception(
        "Document data was null",
      ); // Gestion d'erreur plus robuste
    }
    return BordereauModel(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      commercialId: data['commercialId'] ?? '',
      commentaire: data['commentaire'] ?? '',
      clientEmail: data['clientEmail'] ?? '',
      clientContact: data['clientContact'] ?? '',
      clientAdresse: data['clientAdresse'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      devisId: data['devisId'] ?? '',
      dateLivraison:
          (data['dateLivraison'] as Timestamp?)?.toDate() ?? DateTime.now(),
      etatLivraison: data['etatLivraison'] ?? '',
      delaiGarantie: data['delaiGarantie'] ?? '',
      intitule: data['intitule'] ?? '',
      status: data['status'] ?? 'En attente',
      articles:
          (data['articles'] as List<dynamic>?)
              ?.map(
                (item) =>
                    ArticleLivraison.fromMap(item as Map<String, dynamic>),
              ) // Ajout du cast ici
              .toList() ??
          [],
    );
  }
}

class ArticleLivraison {
  final int ref;
  final String description;
  final int quantity;
  final String status;

  static const String statusRejected = 'Annulé';
  static const String statusPendingValidation = 'En cours de livraison';
  static const String statusValidated = 'Livré';

  ArticleLivraison({
    required this.ref,
    required this.description,
    required this.quantity,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'ref': ref,
      'description': description,
      'quantity': quantity,
      'status': status,
    };
  }

  factory ArticleLivraison.fromMap(Map<String, dynamic> map) {
    return ArticleLivraison(
      ref: map['ref'] ?? 0, // Valeurs par défaut
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? 0,
      status: map['status'] ?? '',
    );
  }

  factory ArticleLivraison.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("ArticleLivraison fromFirestore: Document data was null");
    }
    return ArticleLivraison(
      ref: data['ref'] ?? 0,
      description: data['description'] ?? '',
      quantity: data['quantity'] ?? 0,
      status: data['status'] ?? 'En attente',
    );
  }
  // maintenant au niveau des bordereaux aide moi pour la correction du provider et la mise  en place du servicebordereaux, la soumission du bordereaux, la modification,la
}
