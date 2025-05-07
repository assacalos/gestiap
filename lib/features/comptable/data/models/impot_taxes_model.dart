class ImpotTaxeModel {
  String id;
  String nom;
  double montant;
  DateTime dateDeclaration;
  DateTime datePaiement;
  String statutPaiement; // 'En attente', 'Payé', 'En retard'

  ImpotTaxeModel({
    required this.id,
    required this.nom,
    required this.montant,
    required this.dateDeclaration,
    required this.datePaiement,
    required this.statutPaiement,
  });

  // Factory constructor pour créer un ImpotTaxeModel à partir d'une Map (utile pour la base de données)
  factory ImpotTaxeModel.fromMap(Map<String, dynamic> map) {
    return ImpotTaxeModel(
      id: map['id'],
      nom: map['nom'],
      montant: map['montant'].toDouble(), // Assurez-vous de convertir en double
      dateDeclaration: DateTime.parse(map['dateDeclaration']),
      datePaiement: DateTime.parse(map['datePaiement']),
      statutPaiement: map['statutPaiement'],
    );
  }

  // Méthode pour convertir un ImpotTaxeModel en Map (utile pour la base de données)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'montant': montant,
      'dateDeclaration': dateDeclaration.toIso8601String(),
      'datePaiement': datePaiement.toIso8601String(),
      'statutPaiement': statutPaiement,
    };
  }
}
