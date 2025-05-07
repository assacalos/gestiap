class InterventionModel {
  String id;
  String stockId; // ID de l'équipement concerné
  // ou de la pièce de rechange
  String? stockName; // Nom de l'équipement ou de la pièce de rechange
  // (optionnel, peut être rempli lors de la récupération des données)
  String clientId; // ID du client concerné
  String?
  clientName; // Nom du client (optionnel, peut être rempli lors de la récupération des données)
  String titre;
  String description;
  DateTime dateIntervention;
  String statut; // Planifiée, En cours, Terminée, Annulée
  String technicien; // Nom du technicien
  String? rapport; // Rapport d'intervention (optionnel)

  InterventionModel({
    required this.id,
    required this.stockId,
    required this.clientId,
    this.clientName,
    this.stockName,
    required this.titre,
    required this.description,
    required this.dateIntervention,
    required this.statut,
    required this.technicien,
    this.rapport,
  });

  factory InterventionModel.fromMap(Map<String, dynamic> map) {
    return InterventionModel(
      id: map['id'],
      stockId: map['stockId'],
      stockName: map['stockName'],
      clientId: map['clientId'],
      clientName: map['clientName'],
      titre: map['titre'],
      description: map['description'],
      dateIntervention: DateTime.parse(map['dateIntervention']),
      statut: map['statut'],
      technicien: map['technicien'],
      rapport: map['rapport'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stockId': stockId,
      'stockName': stockName,
      'clientId': clientId,
      'clientName': clientName,
      'titre': titre,
      'description': description,
      'dateIntervention': dateIntervention.toIso8601String(),
      'statut': statut,
      'technicien': technicien,
      'rapport': rapport,
    };
  }
}
