class StockItem {
  final String id;
  final String codeProduit;
  final String description;
  final double prixVenteUnitaire;
  final int quantiteEntree;
  String? quantiteEnStock;
  final double prixAchatUnitaire;
  final DateTime dateAjout;

  StockItem({
    required this.id,
    required this.codeProduit,
    String? quantiteEnStock,
    required this.description,
    required this.prixVenteUnitaire,
    required this.quantiteEntree,
    required this.prixAchatUnitaire,
    DateTime? dateAjout,
  }) : dateAjout = dateAjout ?? DateTime.now();

  StockItem copyWith({
    String? id,
    String? codeProduit,
    String? quantiteEnStock,
    String? description,
    double? prixVenteUnitaire,
    int? quantiteEntree,
    double? prixAchatUnitaire,
    DateTime? dateAjout,
  }) {
    return StockItem(
      id: id ?? this.id,
      codeProduit: codeProduit ?? this.codeProduit,
      quantiteEnStock: quantiteEnStock ?? this.quantiteEnStock,
      description: description ?? this.description,
      prixVenteUnitaire: prixVenteUnitaire ?? this.prixVenteUnitaire,
      quantiteEntree: quantiteEntree ?? this.quantiteEntree,
      prixAchatUnitaire: prixAchatUnitaire ?? this.prixAchatUnitaire,
      dateAjout: dateAjout ?? this.dateAjout,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codeProduit': codeProduit,
      'description': description,
      'quantiteEnStock': quantiteEnStock,
      'prixVenteUnitaire': prixVenteUnitaire,
      'quantiteEntree': quantiteEntree,
      'prixAchatUnitaire': prixAchatUnitaire,
      'dateAjout': dateAjout.toIso8601String(),
    };
  }

  factory StockItem.fromMap(Map<String, dynamic> map, String? id) {
    return StockItem(
      id: id ?? '',
      codeProduit: map['codeProduit'] ?? '',
      description: map['description'] ?? '',
      quantiteEnStock: map['quantiteEnStock']?.toString(),
      prixVenteUnitaire: (map['prixVenteUnitaire'] ?? 0.0).toDouble(),
      quantiteEntree: (map['quantiteEntree'] ?? 0).toInt(),
      prixAchatUnitaire: (map['prixAchatUnitaire'] ?? 0.0).toDouble(),
      dateAjout: DateTime.parse(map['dateAjout']),
    );
  }
}
