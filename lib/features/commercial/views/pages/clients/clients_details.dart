import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart'; // Importez le modèle Client
// import des autres fichiers à créer

class ClientInfoScreen extends StatelessWidget {
  final Client client;

  ClientInfoScreen({required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Informations Client',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue, // Couleur de l'app bar
        elevation: 0, // Supprime l'ombre sous l'app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Augmente le padding
        child: SingleChildScrollView(
          // Permet de scroller si le contenu est trop long
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Détails du Client'), // Titre de section
              _buildDetailRow('Entreprise', client.entreprise),
              _buildDetailRow('Nom', client.nom),
              _buildDetailRow(
                'Adresse',
                client.adresse ?? 'N/A',
              ), // Gère les valeurs null
              _buildDetailRow('Email', client.email),
              _buildDetailRow('Téléphone', client.telephone),
              _buildDetailRow(
                'Situation Géographique',
                client.situationGeographique,
              ),
              SizedBox(height: 30), // Espacement plus grand

              _buildSectionTitle('Actions'), // Titre de section
              Wrap(
                // Permet aux boutons de passer à la ligne sur les petits écrans
                spacing: 10, // Espacement horizontal entre les boutons
                runSpacing:
                    10, // Espacement vertical entre les lignes de boutons
                children: [
                  _buildActionButton(context, 'Proformas', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PlaceholderScreen(
                              title: 'Proformas',
                              clientId: client.id,
                            ),
                      ),
                    );
                  }),
                  _buildActionButton(context, 'Bordereaux', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PlaceholderScreen(
                              title: 'Bordereaux',
                              clientId: client.id,
                            ),
                      ),
                    );
                  }),
                  _buildActionButton(context, 'Bons de Commande', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PlaceholderScreen(
                              title: 'Bons de Commande',
                              clientId: client.id,
                            ),
                      ),
                    );
                  }),
                  _buildActionButton(context, 'Avoirs', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PlaceholderScreen(
                              title: 'Avoirs',
                              clientId: client.id,
                            ),
                      ),
                    );
                  }),
                  _buildActionButton(context, 'Règlements', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PlaceholderScreen(
                              title: 'Règlements',
                              clientId: client.id,
                            ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode pour construire les lignes de détails
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label + ':',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // Refactorisation de la méthode pour construire les boutons
  Widget _buildActionButton(
    BuildContext context,
    String title,
    void Function() onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ), // Padding plus grand
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // Bords arrondis
        backgroundColor: Colors.blue, // Couleur du bouton
        foregroundColor: Colors.white, // Couleur du texte
        elevation: 2, // Ajoute une petite ombre
      ),
      child: Text(title, style: TextStyle(fontSize: 16)),
    );
  }
}

// PlaceholderScreen (à remplacer par vos vrais écrans)
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String clientId;

  PlaceholderScreen({required this.title, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Écran pour $title (Client ID: $clientId)',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Contenu à implémenter...',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Retour à la page précédente"),
            ),
          ],
        ),
      ),
    );
  }
}

//Nouvelle méthode pour les titres des sections
Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue, // Couleur des titres
      ),
    ),
  );
}
