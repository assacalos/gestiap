class EmployeModel {
  String id;
  String nom;
  String prenom;
  String email;
  String telephone;
  String poste;
  String departement;
  DateTime dateEmbauche;

  EmployeModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.poste,
    required this.departement,
    required this.dateEmbauche,
  });

  factory EmployeModel.fromMap(Map<String, dynamic> map) {
    return EmployeModel(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
      telephone: map['telephone'],
      poste: map['poste'],
      departement: map['departement'],
      dateEmbauche: DateTime.parse(map['dateEmbauche']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'poste': poste,
      'departement': departement,
      'dateEmbauche': dateEmbauche.toIso8601String(),
    };
  }
}
