/* import 'package:flutter/material.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';
import 'package:gestiap/features/commercial/views/pages/clients/clients_details.dart';
import 'package:gestiap/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ClientsPage extends StatefulWidget {
  final String status;
  final List<Client> clients;
  const ClientsPage({super.key, required this.status, required this.clients});

  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  ScrollController _scrollController = ScrollController();
  int _currentPageIndex = 0;
  String _searchQuery = '';
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _entrepriseController = TextEditingController();
  final _adresseController = TextEditingController();
  final _situationGeoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).loadClients();
    });
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        Provider.of<ClientProvider>(context, listen: false).loadClients();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);

    final filteredClients =
        clientProvider.clients.where((client) {
          return client.nom.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              client.entreprise.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
        }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Gestion des Clients")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                labelText: 'Rechercher un client',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child:
                clientProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : clientProvider.errorMessage != null
                    ? Center(child: Text(clientProvider.errorMessage!))
                    : ListView.builder(
                      itemCount: filteredClients.length,
                      itemBuilder: (context, index) {
                        final client = filteredClients[index];
                        return ListTile(
                          title: Text(client.entreprise),
                          subtitle: Text(client.nom),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed:
                                    () =>
                                        _showEditClientDialog(context, client),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.details,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ClientInfoScreen(
                                              client: client,
                                            ),
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClientDialog(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabChange: (index) => setState(() => _currentPageIndex = index),
        initialIndex: _currentPageIndex,
      ),
    );
  }

  void _showAddClientDialog(BuildContext context) {
    _clearForm();
    _showClientDialog(context, isEditing: false);
  }

  void _showEditClientDialog(BuildContext context, Client client) {
    _nomController.text = client.nom;
    _emailController.text = client.email;
    _telephoneController.text = client.telephone;
    _adresseController.text = client.adresse ?? '';
    _situationGeoController.text = client.situationGeographique;
    _entrepriseController.text = client.entreprise;
    _showClientDialog(context, isEditing: true, client: client);
  }

  void _showClientDialog(
    BuildContext context, {
    required bool isEditing,
    Client? client,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isEditing ? "Modifier Client" : "Ajouter un Client"),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(_entrepriseController, "Entreprise"),
                    _buildTextField(_nomController, "Nom Référent"),
                    _buildTextField(_telephoneController, "Téléphone"),
                    _buildTextField(_emailController, "Email"),
                    _buildTextField(_adresseController, "Adresse"),
                    _buildTextField(
                      _situationGeoController,
                      "Situation géographique",
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    isEditing
                        ? _updateClient(context, client!)
                        : _saveClient(context);
                  }
                },
                child: Text(isEditing ? "Modifier" : "Ajouter"),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator:
          (value) => value == null || value.isEmpty ? 'Champ requis' : null,
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
        situationGeographique: _situationGeoController.text,
        id: '',
        commercialId: currentUserId,
      );

      await Provider.of<ClientProvider>(
        context,
        listen: false,
      ).addClient(newClient, context);
      Navigator.pop(context);
    }
  }

  Future<void> _updateClient(BuildContext context, Client client) async {
    final updatedClient = Client(
      id: client.id,
      nom: _nomController.text,
      email: _emailController.text,
      telephone: _telephoneController.text,
      adresse: _adresseController.text,
      situationGeographique: _situationGeoController.text,
      entreprise: _entrepriseController.text,
      commercialId: client.commercialId,
    );

    await Provider.of<ClientProvider>(
      context,
      listen: false,
    ).updateClient(updatedClient, context);
    Navigator.pop(context);
  }

  void _clearForm() {
    _nomController.clear();
    _emailController.clear();
    _telephoneController.clear();
    _entrepriseController.clear();
    _adresseController.clear();
    _situationGeoController.clear();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _entrepriseController.dispose();
    _adresseController.dispose();
    _situationGeoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
 */
