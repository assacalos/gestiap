class Client {
  String id;
  String nom;
  String email;
  String telephone;
  String entreprise;
  String adresse;
  String commercialId;
  String situationGeographique =
      ''; // Valeur par défaut pour situationGeographique
  String? commentaire; // Champ commentaire optionnel
  String status; // Champ statut optionnel

  Client({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.entreprise,
    required this.situationGeographique,
    required this.adresse,
    this.commercialId = '', // Valeur par défaut pour commercialId
    this.status = statusSubmitted,
    this.commentaire, // Champ commentaire optionnel
  });
  // Définition des constantes statiques pour les statuts
  static const String statusSubmitted = 'Soumis';
  static const String statusValidated = 'Validé';
  static const String statusRejected = 'Rejeté';
  static const String statusPendingValidation =
      'En attente de validation'; // Nouveau statut
  // Convertir un client en Map pour Firestore
  // Méthode pour convertir un objet Client en Map<String, dynamic> pour Firebase (toJson)

  Client copyWith({
    String? id,
    String? nom,
    String? email,
    String? telephone,
    String? entreprise,
    String? adresse,
    String? situationGeographique,
    String? commercialId,
    String? status,
    String? commentaire, // Champ commentaire optionnel
  }) {
    return Client(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      entreprise: entreprise ?? this.entreprise,
      adresse: adresse ?? this.adresse,
      situationGeographique:
          situationGeographique ?? this.situationGeographique,
      commercialId: commercialId ?? this.commercialId, // Inclure commercialId
      status: status ?? this.status, // Inclure status
      commentaire: commentaire ?? this.commentaire, // Inclure commentaire
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'entreprise': entreprise,
      'adresse': adresse,
      'situationGeographique': situationGeographique,
      'commercialId': commercialId, // Inclure commercialId dans le Map
      'status': status,
      'commentaire': commentaire, // Inclure commentaire dans le Map
    };
  }

  // Créer un client depuis un document Firestore
  // Factory constructor pour créer un objet Client à partir d'un Map<String, dynamic> de Firebase (fromJson)
  factory Client.fromMap(Map<String, dynamic> data, String documentId) {
    return Client(
      id: documentId,
      nom: data['nom'] ?? '',
      email: data['email'] ?? '',
      telephone: data['telephone'] ?? '',
      entreprise: data['entreprise'] ?? '',
      adresse: data['adresse'] ?? '',
      situationGeographique:
          data['situationGeographique'] ?? '', // Inclure situationGeographique
      commercialId: data['commercialId'] ?? '', // Inclure commercialId
      status: data['status'] ?? statusSubmitted,
      commentaire: data['commentaire'], // Inclure commentaire
    );
  }
  /* La méthode loadClients() interroge Firebase Firestore pour récupérer les documents (await _firestore.collection('clients').get();).
Pour chaque DocumentSnapshot reçu de Firestore, elle utilise le factory Client.fromFirestore(doc) (ou Client.fromMap(map, documentId)) défini dans le ClientModel.
Cette méthode fromFirestore prend le DocumentSnapshot (qui contient les données sous forme de Map) et crée un objet Client bien typé en Dart.

 */
}
