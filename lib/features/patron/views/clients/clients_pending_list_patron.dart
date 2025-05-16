import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';

class ClientPendingList extends StatefulWidget {
  const ClientPendingList({super.key});

  @override
  State<ClientPendingList> createState() => _ClientPendingListState();
}

class _ClientPendingListState extends State<ClientPendingList> {
  final TextEditingController _rejectionReasonController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Make the callback async
      final clientProvider = Provider.of<ClientProvider>(
        context,
        listen: false,
      );
      await clientProvider.loadAllClients(); // Await the loading of clients

      // Print the clients to the console
      print("Loaded clients: ${clientProvider.clients}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final pendingClients =
        clientProvider.clients
            .where((q) => q.status == Client.statusPendingValidation)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clients en Attente"),
        backgroundColor: Colors.amber,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body:
          pendingClients.isEmpty
              ? const Center(child: Text("Aucun client en attente."))
              : ListView.builder(
                itemCount: pendingClients.length,
                itemBuilder: (context, index) {
                  final client = pendingClients[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        client.nom,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Entreprise: ${client.entreprise}"),
                          Text("Email: ${client.email}"),
                          Text("Téléphone: ${client.telephone}"),
                          Text("Adresse: ${client.adresse}"),
                          Text(
                            "Situation Géo: ${client.situationGeographique}",
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                            onPressed:
                                () => _showValidateConfirmationDialog(
                                  context,
                                  clientProvider,
                                  client,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.cancel_outlined,
                              color: Colors.red,
                            ),
                            onPressed:
                                () => _showRejectDialog(
                                  context,
                                  clientProvider,
                                  client,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Future<void> _showValidateConfirmationDialog(
    BuildContext context,
    ClientProvider clientProvider,
    Client client,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirmer Validation"),
            content: Text(
              "Voulez-vous vraiment valider le client ${client.nom} ?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Valider"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await clientProvider.validateClient(client.id);
    }
  }

  Future<void> _showRejectDialog(
    BuildContext context,
    ClientProvider clientProvider,
    Client client,
  ) async {
    _rejectionReasonController.clear();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Rejeter Client"),
            content: TextField(
              controller: _rejectionReasonController,
              decoration: const InputDecoration(
                labelText: "Motif du rejet",
                hintText: "Entrez la raison du rejet...",
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final reason = _rejectionReasonController.text.trim();
                  if (reason.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Le motif de rejet est obligatoire."),
                      ),
                    );
                    return;
                  }

                  await clientProvider.rejectClient(client.id, reason);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Rejeter"),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }
}
