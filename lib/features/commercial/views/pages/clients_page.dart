import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/views/providers/clients_provider.dart';
import 'package:provider/provider.dart';

class ClientsPage extends StatefulWidget {
  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  int _currentPageIndex = 0;
  @override
  void initState() {
    super.initState();
    Provider.of<ClientProvider>(context, listen: false).loadClients();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Gestion des Clients")),
      body: ListView.builder(
        itemCount: clientProvider.clients.length,
        itemBuilder: (context, index) {
          final client = clientProvider.clients[index];
          return ListTile(
            title: Text(client.nom),
            subtitle: Text(client.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditClientDialog(context, client),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => clientProvider.deleteClient(client.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClientDialog(context),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabChange: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        initialIndex: _currentPageIndex,
      ),
    );
  }

  void _showAddClientDialog(BuildContext context) {
    final _nomController = TextEditingController();
    final _emailController = TextEditingController();
    final _telephoneController = TextEditingController();
    final _entrepriseController = TextEditingController();
    final _adresseController = TextEditingController();
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Ajouter un Client"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomController,
                decoration: InputDecoration(labelText: "Nom et Prénom"),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: _telephoneController,
                decoration: InputDecoration(labelText: "Téléphone"),
              ),
              TextField(
                controller: _adresseController,
                decoration: InputDecoration(labelText: "Adresse"),
              ),
              TextField(
                controller: _entrepriseController,
                decoration: InputDecoration(labelText: "Entreprise"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                final newClient = Client(
                  id: '',
                  nom: _nomController.text,
                  email: _emailController.text,
                  telephone: _telephoneController.text,
                  adresse: _adresseController.text,
                  entreprise: _entrepriseController.text,
                );
                clientProvider.addClient(newClient);
                Navigator.pop(context);
              },
              child: Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  void _showEditClientDialog(BuildContext context, Client client) {
    final _nomController = TextEditingController(text: client.nom);
    final _emailController = TextEditingController(text: client.email);
    final _telephoneController = TextEditingController(text: client.telephone);
    final _adresseController = TextEditingController(text: client.adresse);
    final _entrepriseController = TextEditingController(
      text: client.entreprise,
    );
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modifier Client"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomController,
                decoration: InputDecoration(labelText: "Nom"),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: _telephoneController,
                decoration: InputDecoration(labelText: "Téléphone"),
              ),
              TextField(
                controller: _adresseController,
                decoration: InputDecoration(labelText: "Adresse"),
              ),
              TextField(
                controller: _entrepriseController,
                decoration: InputDecoration(labelText: "Entreprise"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedClient = Client(
                  id: client.id,
                  nom: _nomController.text,
                  email: _emailController.text,
                  telephone: _telephoneController.text,
                  adresse: _adresseController.text,
                  entreprise: _entrepriseController.text,
                );
                clientProvider.updateClient(updatedClient);
                Navigator.pop(context);
              },
              child: Text("Modifier"),
            ),
          ],
        );
      },
    );
  }
}
