import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';
import 'package:gestiap/features/commercial/utils/Proforma_pdf_generator.dart';
import 'package:gestiap/features/commercial/views/pages/clients/client_modifier_form.dart';
import 'package:gestiap/features/commercial/views/pages/clients/clients_details.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/proforma_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/proforma_form_page.dart';

class ListeClientPage extends StatefulWidget {
  final String status;
  final List<Client> clients;

  const ListeClientPage({Key? key, required this.clients, required this.status})
    : super(key: key); // Ajout de Key? key
  @override
  _ListeClientPageState createState() => _ListeClientPageState();
}

class _ListeClientPageState extends State<ListeClientPage> {
  int _currentPageIndex = 0; // Indice de la page actuelle pour la navigation
  List<Client> _filteredClients =
      []; // Stocker la liste filtrée dans l'état local
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String get status => widget.status;

  @override
  void initState() {
    super.initState();
    _filterClients(); // Filtrer les clients lors de l'initialisation
  }

  @override
  void didUpdateWidget(ListeClientPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Vérifie si la liste des clients ou le statut a changé
    if (oldWidget.clients != widget.clients ||
        oldWidget.status != widget.status) {
      _filterClients();
    }
  }

  void _filterClients() {
    // Méthode pour filtrer les clients
    _filteredClients =
        widget.clients.where((client) {
          final nomComplet =
              '${client.nom} ${client.entreprise}'
                  .toLowerCase(); // Simplifie la recherche

          // Filtre par nom/entreprise ET par statut.  widget.status peut être null.
          final statutCorrespond =
              widget.status == null ||
              client.status.toLowerCase() == widget.status!.toLowerCase();

          return nomComplet.contains(_searchQuery.toLowerCase()) &&
              statutCorrespond;
        }).toList();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Clients')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Rechercher des clients',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterClients();
                });
              },
            ),
          ),
          Expanded(
            child:
                clientProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredClients.isEmpty
                    ? const Center(child: Text('Aucun client trouvé.'))
                    : ListView.builder(
                      itemCount: _filteredClients.length,
                      itemBuilder: (context, index) {
                        final client = _filteredClients[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: const Icon(
                              Icons.business_center,
                            ), // Ajoute une icône
                            title: Text('${client.nom} ${client.entreprise}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${client.email}'),
                                Text('Téléphone: ${client.telephone}'),
                                Text('Statut: ${client.status}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (client.status.toLowerCase() ==
                                    QuoteModel.statusRejected.toLowerCase())
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ClientFormPage(),
                                        ),
                                      );
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ClientInfoScreen(
                                              client: client,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                //Seul les clients rejetes peuvent etre supprimes
                                if (client.adresse ==
                                    'Rejeté') // Utilisez ici le champ qui convient, j'ai mis adresse par défaut car je n'ai pas de champ status
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                        context,
                                        client,
                                        clientProvider,
                                      );
                                    },
                                  ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ClientInfoScreen(client: client),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
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

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    Client client,
    ClientProvider clientProvider,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Êtes-vous sûr de vouloir supprimer le client ${client.entreprise} ${client.nom}?',
                ),
                const Text('Cette action est irréversible.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
              onPressed: () {
                clientProvider.deleteClient(
                  client.id,
                ); // Appel de la fonction de suppression
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Client supprimé.')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
