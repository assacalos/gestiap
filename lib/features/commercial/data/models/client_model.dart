class Client {
  String id;
  String nom;
  String email;
  String telephone;
  String entreprise;
  String adresse;
  String commercialId;

  Client({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.entreprise,
    required this.adresse,
    this.commercialId = '', // Valeur par défaut pour commercialId
  });

  // Convertir un client en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'entreprise': entreprise,
      'adresse': adresse,
      'commercialId': commercialId, // Inclure commercialId dans le Map
    };
  }

  // Créer un client depuis un document Firestore
  factory Client.fromMap(Map<String, dynamic> data, String documentId) {
    return Client(
      id: documentId,
      nom: data['nom'] ?? '',
      email: data['email'] ?? '',
      telephone: data['telephone'] ?? '',
      entreprise: data['entreprise'] ?? '',
      adresse: data['adresse'] ?? '',
      commercialId: data['commercialId'] ?? '', // Inclure commercialId
    );
  }
}
