import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';
import 'package:gestiap/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ClientsPage extends StatefulWidget {
  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _entrepriseController = TextEditingController();
  final _adresseController = TextEditingController();
  final _commercialIdController = TextEditingController();
  final _clientIdController = TextEditingController();

  int _currentPageIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).loadClients();
    });
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
                  onPressed:
                      () => clientProvider.deleteClient(client.id, context),
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
    _nomController.clear();
    _emailController.clear();
    _telephoneController.clear();
    _entrepriseController.clear();
    _adresseController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Ajouter un Client"),
          content: Form(
            // Wrap your Column with a Form
            key: _formKey, // Associate the key
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  // Use TextFormField for validation
                  controller: _nomController,
                  decoration: InputDecoration(labelText: "Nom et Prénom"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un email.';
                    }
                    // You can add more sophisticated email validation here
                    if (!value.contains('@')) {
                      return 'Invalid email address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _telephoneController,
                  decoration: InputDecoration(labelText: "Téléphone"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un numéro de téléphone.';
                    }
                    // Add phone number validation if needed
                    return null;
                  },
                ),
                TextFormField(
                  controller: _adresseController,
                  decoration: InputDecoration(labelText: "Adresse"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une adresse.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _entrepriseController,
                  decoration: InputDecoration(labelText: "Entreprise"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom d\'entreprise.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Check if the form is valid
                  _saveClient(context);
                }
              },
              child: Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveClient(BuildContext context) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;

    if (currentUserId != null) {
      final newClient = Client(
        nom: _nomController.text,
        adresse: _adresseController.text,
        email: _emailController.text,
        telephone: _telephoneController.text,
        entreprise: _entrepriseController.text,
        id: '',
        commercialId: currentUserId,
      );

      final clientProvider = Provider.of<ClientProvider>(
        context,
        listen: false,
      );
      try {
        await clientProvider.addClient(newClient, context);
        Navigator.pop(context);
      } catch (e) {
        //Error is already handled by the client provider,
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur : Utilisateur non connecté.")),
      );
    }
  }

  void _showEditClientDialog(BuildContext context, Client client) {
    _nomController.text = client.nom;
    _emailController.text = client.email;
    _telephoneController.text = client.telephone;
    _adresseController.text = client.adresse;
    _entrepriseController.text = client.entreprise;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modifier Client"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(labelText: "Nom"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un email.';
                    }
                    if (!value.contains('@')) {
                      return 'Invalid email address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _telephoneController,
                  decoration: InputDecoration(labelText: "Téléphone"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un numéro de téléphone.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _adresseController,
                  decoration: InputDecoration(labelText: "Adresse"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une adresse.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _entrepriseController,
                  decoration: InputDecoration(labelText: "Entreprise"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom d\'entreprise.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final updatedClient = Client(
                    id: client.id,
                    nom: _nomController.text,
                    email: _emailController.text,
                    telephone: _telephoneController.text,
                    adresse: _adresseController.text,
                    entreprise: _entrepriseController.text,
                    commercialId: client.commercialId,
                  );
                  final clientProvider = Provider.of<ClientProvider>(
                    context,
                    listen: false,
                  );
                  try {
                    clientProvider.updateClient(updatedClient, context);
                    Navigator.pop(context);
                  } catch (e) {}
                }
              },
              child: Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _entrepriseController.dispose();
    super.dispose();
  }
}
