import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class BonDeCommandeModel {
  String? id;
  String clientId;
  String? clientName; // Optionnel, peut être récupéré via l'ID
  String? bordereauId;
  String? proformaId;
  String? documentScanneUrl; // URL du document scanné
  double acompteRecu;
  DateTime createdAt;
  String status;
  String? commentairePatron;

  static const String statusPendingValidation = 'En Attente de Validation';
  static const String statusValidated = 'Validé';
  static const String statusRejected = 'Rejeté';

  BonDeCommandeModel({
    this.id,
    required this.clientId,
    this.clientName,
    this.bordereauId,
    this.proformaId,
    this.documentScanneUrl,
    this.acompteRecu = 0.0,
    required this.createdAt,
    this.status = statusPendingValidation,
    this.commentairePatron,
  });

  BonDeCommandeModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? bordereauId,
    String? proformaId,
    String? documentScanneUrl,
    double? acompteRecu,
    DateTime? createdAt,
    String? status,
    String? commentairePatron,
  }) {
    return BonDeCommandeModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      bordereauId: bordereauId ?? this.bordereauId,
      proformaId: proformaId ?? this.proformaId,
      documentScanneUrl: documentScanneUrl ?? this.documentScanneUrl,
      acompteRecu: acompteRecu ?? this.acompteRecu,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      commentairePatron: commentairePatron ?? this.commentairePatron,
    );
  }

  factory BonDeCommandeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return BonDeCommandeModel(
      id: doc.id,
      clientId: data?['clientId'] ?? '',
      clientName: data?['clientName'],
      bordereauId: data?['bordereauId'],
      proformaId: data?['proformaId'],
      documentScanneUrl: data?['documentScanneUrl'],
      acompteRecu: (data?['acompteRecu'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data?['status'] ?? statusPendingValidation,
      commentairePatron: data?['commentairePatron'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'bordereauId': bordereauId,
      'proformaId': proformaId,
      'documentScanneUrl': documentScanneUrl,
      'acompteRecu': acompteRecu,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'commentairePatron': commentairePatron,
    };
  }
}
