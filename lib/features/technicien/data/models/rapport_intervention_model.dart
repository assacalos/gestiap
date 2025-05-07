class RapportInterventionModel {
  String id;
  String interventionId; // ID de l'intervention concernée
  DateTime dateRapport;
  String description;
  String conclusion;
  String technicien; // Nom du technicien ayant rédigé le rapport

  RapportInterventionModel({
    required this.id,
    required this.interventionId,
    required this.dateRapport,
    required this.description,
    required this.conclusion,
    required this.technicien,
  });

  factory RapportInterventionModel.fromMap(Map<String, dynamic> map) {
    return RapportInterventionModel(
      id: map['id'],
      interventionId: map['interventionId'],
      dateRapport: DateTime.parse(map['dateRapport']),
      description: map['description'],
      conclusion: map['conclusion'],
      technicien: map['technicien'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'interventionId': interventionId,
      'dateRapport': dateRapport.toIso8601String(),
      'description': description,
      'conclusion': conclusion,
      'technicien': technicien,
    };
  }
}
