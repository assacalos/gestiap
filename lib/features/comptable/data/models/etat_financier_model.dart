class EtatFinancierModel {
  String id;
  String typeEtat; // Bilan, Compte de Résultat, Tableau de Flux de Trésorerie
  DateTime dateDebut;
  DateTime dateFin;
  Map<String, double>
  donnees; // Structure flexible pour les données financières
  String devise;

  EtatFinancierModel({
    required this.id,
    required this.typeEtat,
    required this.dateDebut,
    required this.dateFin,
    required this.donnees,
    required this.devise,
  });

  factory EtatFinancierModel.fromMap(Map<String, dynamic> map) {
    // Conversion des données financières (Map<String, dynamic> vers Map<String, double>)
    Map<String, double> donnees = {};
    if (map['donnees'] != null) {
      (map['donnees'] as Map<String, dynamic>).forEach((key, value) {
        if (value is num) {
          // Vérification du type
          donnees[key] = value.toDouble();
        } else {
          // Gérer le cas où la valeur n'est pas un nombre (peut-être une erreur ou une valeur nulle)
          print(
            'Warning: Value for key "$key" in donnees is not a number. Skipping.',
          );
          // Vous pouvez choisir de lever une exception ici si c'est inattendu.
        }
      });
    }

    return EtatFinancierModel(
      id: map['id'],
      typeEtat: map['typeEtat'],
      dateDebut: DateTime.parse(map['dateDebut']),
      dateFin: DateTime.parse(map['dateFin']),
      donnees: donnees,
      devise: map['devise'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'typeEtat': typeEtat,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
      'donnees': donnees,
      'devise': devise,
    };
  }

  @override
  String toString() {
    return 'EtatFinancierModel{id: $id, typeEtat: $typeEtat, dateDebut: $dateDebut, dateFin: $dateFin, donnees: $donnees, devise: $devise}';
  }
}
