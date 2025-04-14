import 'package:cloud_firestore/cloud_firestore.dart';

class FournisseurModel {
  String? id;
  String nom;
  String? entreprise;
  String? adresse;
  String? contact;
  String? email;
  String? informationsBancaires; // Optionnel

  FournisseurModel({
    this.id,
    required this.nom,
    this.entreprise,
    this.adresse,
    this.contact,
    this.email,
    this.informationsBancaires,
  });

  factory FournisseurModel.fromJson(Map<String, dynamic> json) {
    return FournisseurModel(
      id: json['id'],
      nom: json['nom'],
      entreprise: json['entreprise'],
      adresse: json['adresse'],
      contact: json['contact'],
      email: json['email'],
      informationsBancaires: json['informationsBancaires'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'entreprise': entreprise,
      'adresse': adresse,
      'contact': contact,
      'email': email,
      'informationsBancaires': informationsBancaires,
    };
  }

  FournisseurModel copyWith({
    String? id,
    String? nom,
    String? entreprise,
    String? adresse,
    String? contact,
    String? email,
    String? informationsBancaires,
  }) {
    return FournisseurModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      entreprise: entreprise ?? this.entreprise,
      adresse: adresse ?? this.adresse,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      informationsBancaires:
          informationsBancaires ?? this.informationsBancaires,
    );
  }
}
