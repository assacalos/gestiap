import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String userRole; // Rôle de l'utilisateur connecté

  const HomeScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GestApp'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Gestion des notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Gestion du profil
            },
          ),
        ],
      ),
      body: _buildHomeScreenContent(userRole),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeScreenContent(String userRole) {
    switch (userRole) {
      case 'commercial':
        return CommercialDashboard();
      case 'patron':
        return PatronDashboard();
      case 'comptable':
        return ComptableDashboard();
      case 'technicien':
        return TechnicienDashboard();
      default:
        return Center(child: Text('Tableau de bord par défaut'));
    }
  }
}

// Tableaux de bord personnalisés pour chaque rôle
class CommercialDashboard extends StatelessWidget {
  const CommercialDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Clients à contacter',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          // Liste des clients à contacter
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              ListTile(title: Text('Client A'), subtitle: Text('Entreprise X')),
              ListTile(title: Text('Client B'), subtitle: Text('Entreprise Y')),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Devis en cours',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          // Liste des devis en cours
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              ListTile(title: Text('Devis #123'), subtitle: Text('En attente')),
              ListTile(title: Text('Devis #456'), subtitle: Text('Envoyé')),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Factures impayées',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          // Liste des factures impayées
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              ListTile(
                title: Text('Facture #789'),
                subtitle: Text('Date d\'échéance: 2023-12-31'),
              ),
              ListTile(
                title: Text('Facture #101'),
                subtitle: Text('Date d\'échéance: 2024-01-15'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PatronDashboard extends StatelessWidget {
  const PatronDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Tableau de bord du patron'));
  }
}

class ComptableDashboard extends StatelessWidget {
  const ComptableDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Tableau de bord des comptables'));
  }
}

class TechnicienDashboard extends StatelessWidget {
  const TechnicienDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Tableau de bord des techniciens'));
  }
}
