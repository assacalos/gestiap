import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  String? id;
  String nom;
  DateTime dateDebut;
  DateTime dateFin;
  Map<String, double> categories; // Catégorie de dépense -> Montant budgété

  BudgetModel({
    this.id,
    required this.nom,
    required this.dateDebut,
    required this.dateFin,
    required this.categories,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      nom: json['nom'],
      dateDebut: (json['dateDebut'] as Timestamp).toDate(),
      dateFin: (json['dateFin'] as Timestamp).toDate(),
      categories: (json['categories'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'categories': categories,
    };
  }

  BudgetModel copyWith({
    String? id,
    String? nom,
    DateTime? dateDebut,
    DateTime? dateFin,
    Map<String, double>? categories,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      categories: categories ?? this.categories,
    );
  }
}
