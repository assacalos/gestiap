class EquipementModel {
  String id;
  String nom;
  String type;
  String marque;
  String modele;
  String numeroSerie;
  DateTime dateAchat;
  String etat; // En service, En maintenance, Réformé

  EquipementModel({
    required this.id,
    required this.nom,
    required this.type,
    required this.marque,
    required this.modele,
    required this.numeroSerie,
    required this.dateAchat,
    required this.etat,
  });

  factory EquipementModel.fromMap(Map<String, dynamic> map) {
    return EquipementModel(
      id: map['id'],
      nom: map['nom'],
      type: map['type'],
      marque: map['marque'],
      modele: map['modele'],
      numeroSerie: map['numeroSerie'],
      dateAchat: DateTime.parse(map['dateAchat']),
      etat: map['etat'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'type': type,
      'marque': marque,
      'modele': modele,
      'numeroSerie': numeroSerie,
      'dateAchat': dateAchat.toIso8601String(),
      'etat': etat,
    };
  }
}
