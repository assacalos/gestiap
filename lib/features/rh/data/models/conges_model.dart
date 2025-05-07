class CongeModel {
  String id;
  String employeId; // ID de l'employé concerné
  DateTime dateDebut;
  DateTime dateFin;
  String typeConge; // Congé payé, Congé maladie, etc.
  String statut; // En attente, Approuvé, Refusé
  String motif; // Motif de la demande de congé

  CongeModel({
    required this.id,
    required this.employeId,
    required this.dateDebut,
    required this.dateFin,
    required this.typeConge,
    required this.statut,
    required this.motif,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeId': employeId,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
      'typeConge': typeConge,
      'statut': statut,
      'motif': motif,
    };
  }

  factory CongeModel.fromMap(Map<String, dynamic> map) {
    return CongeModel(
      id: map['id'],
      employeId: map['employeId'],
      dateDebut: DateTime.parse(map['dateDebut']),
      dateFin: DateTime.parse(map['dateFin']),
      typeConge: map['typeConge'],
      statut: map['statut'],
      motif: map['motif'],
    );
  }
}
