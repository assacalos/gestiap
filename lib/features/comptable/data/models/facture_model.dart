import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceModel {
  String id;
  String clientId;
  String clientName;
  DateTime dateCreation;
  DateTime? dateEcheance;
  List<InvoiceItem> items;
  double totalHT;
  double totalTTC;
  double montantTVA;
  double? montantPaye;
  String status;
  String? reference;
  String? commentaireRejet;

  InvoiceModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.dateCreation,
    this.dateEcheance,
    required this.items,
    required this.totalHT,
    required this.totalTTC,
    required this.montantTVA,
    this.montantPaye,
    required this.status,
    this.reference,
    this.commentaireRejet,
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
      montantTVA: (json['montantTva'] as num).toDouble(),
      montantPaye:
          json['montantPaye'] != null
              ? (json['montantPaye'] as num).toDouble()
              : null,
      status: json['status'],
      reference: json['reference'],
      commentaireRejet: json['commentaireRejet'],
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
      'montantTva': montantTVA,
      'montantPaye': montantPaye,
      'status': status,
      'reference': reference,
      'commentaireRejet': commentaireRejet,
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
    double? montantTVA,
    double? montantPaye,
    String? status,
    String? reference,
    String? commentaireRejet,
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
      montantTVA: montantTVA ?? this.montantTVA,
      montantPaye: montantPaye ?? this.montantPaye,
      status: status ?? this.status,
      reference: reference ?? this.reference,
      commentaireRejet: commentaireRejet ?? this.commentaireRejet,
    );
  }

  static const String statusValidated = 'validée';
  static const String statusSubmitted = 'Soumise';
  static const String statusPayee = 'Payée';
  static const String statusRejected = 'Rejetée';
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
