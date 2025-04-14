import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceModel {
  String? id;
  String clientId;
  String clientName;
  DateTime dateCreation;
  DateTime? dateEcheance;
  List<InvoiceItem> items;
  double totalHT;
  double totalTTC;
  double? montantPaye;
  String status; // 'Brouillon', 'Soumise', 'Payée', 'Impayée'
  String? reference;

  InvoiceModel({
    this.id,
    required this.clientId,
    required this.clientName,
    required this.dateCreation,
    this.dateEcheance,
    required this.items,
    required this.totalHT,
    required this.totalTTC,
    this.montantPaye,
    required this.status,
    this.reference,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      dateCreation: (json['dateCreation'] as Timestamp).toDate(),
      dateEcheance:
          json['dateEcheance'] != null
              ? (json['dateEcheance'] as Timestamp).toDate()
              : null,
      items:
          (json['items'] as List<dynamic>)
              .map((item) => InvoiceItem.fromJson(item))
              .toList(),
      totalHT: (json['totalHT'] as num).toDouble(),
      totalTTC: (json['totalTTC'] as num).toDouble(),
      montantPaye:
          json['montantPaye'] != null
              ? (json['montantPaye'] as num).toDouble()
              : null,
      status: json['status'],
      reference: json['reference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'dateCreation': dateCreation,
      'dateEcheance': dateEcheance,
      'items': items.map((item) => item.toJson()).toList(),
      'totalHT': totalHT,
      'totalTTC': totalTTC,
      'montantPaye': montantPaye,
      'status': status,
      'reference': reference,
    };
  }

  InvoiceModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    DateTime? dateCreation,
    DateTime? dateEcheance,
    List<InvoiceItem>? items,
    double? totalHT,
    double? totalTTC,
    double? montantPaye,
    String? status,
    String? reference,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      dateCreation: dateCreation ?? this.dateCreation,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      items: items ?? this.items,
      totalHT: totalHT ?? this.totalHT,
      totalTTC: totalTTC ?? this.totalTTC,
      montantPaye: montantPaye ?? this.montantPaye,
      status: status ?? this.status,
      reference: reference ?? this.reference,
    );
  }

  static const String statusBrouillon = 'Brouillon';
  static const String statusSoumise = 'Soumise';
  static const String statusPayee = 'Payée';
  static const String statusImpayee = 'Impayée';
}

class InvoiceItem {
  String description;
  double unitPrice;
  int quantity;

  InvoiceItem({
    required this.description,
    required this.unitPrice,
    required this.quantity,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'unitPrice': unitPrice,
      'quantity': quantity,
    };
  }
}
