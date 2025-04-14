import 'package:cloud_firestore/cloud_firestore.dart';

class DepenseModel {
  String? id;
  String description;
  DateTime date;
  double montant;
  String categorie;
  String? fournisseurId;
  String? fournisseurNom;
  String? reference;
  String? methodePaiement; // Nouvelle propriété
  String?
  pieceJustificativeUrl; // Nouvelle propriété pour l'URL de la pièce jointe

  DepenseModel({
    this.id,
    required this.description,
    required this.date,
    required this.montant,
    required this.categorie,
    this.fournisseurId,
    this.fournisseurNom,
    this.reference,
    this.methodePaiement,
    this.pieceJustificativeUrl,
  });

  factory DepenseModel.fromJson(Map<String, dynamic> json) {
    return DepenseModel(
      id: json['id'],
      description: json['description'],
      date: (json['date'] as Timestamp).toDate(),
      montant: (json['montant'] as num).toDouble(),
      categorie: json['categorie'],
      fournisseurId: json['fournisseurId'],
      fournisseurNom: json['fournisseurNom'],
      reference: json['reference'],
      methodePaiement: json['methodePaiement'],
      pieceJustificativeUrl: json['pieceJustificativeUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'date': date,
      'montant': montant,
      'categorie': categorie,
      'fournisseurId': fournisseurId,
      'fournisseurNom': fournisseurNom,
      'reference': reference,
      'methodePaiement': methodePaiement,
      'pieceJustificativeUrl': pieceJustificativeUrl,
    };
  }

  DepenseModel copyWith({
    String? id,
    String? description,
    DateTime? date,
    double? montant,
    String? categorie,
    String? fournisseurId,
    String? fournisseurNom,
    String? reference,
    String? methodePaiement,
    String? pieceJustificativeUrl,
  }) {
    return DepenseModel(
      id: id ?? this.id,
      description: description ?? this.description,
      date: date ?? this.date,
      montant: montant ?? this.montant,
      categorie: categorie ?? this.categorie,
      fournisseurId: fournisseurId ?? this.fournisseurId,
      fournisseurNom: fournisseurNom ?? this.fournisseurNom,
      reference: reference ?? this.reference,
      methodePaiement: methodePaiement ?? this.methodePaiement,
      pieceJustificativeUrl:
          pieceJustificativeUrl ?? this.pieceJustificativeUrl,
    );
  }
}
