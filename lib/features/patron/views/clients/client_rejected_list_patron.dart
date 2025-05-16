import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';

class ClientRejete extends StatefulWidget {
  const ClientRejete({super.key});

  @override
  State<ClientRejete> createState() => _ClientRejeteState();
}

class _ClientRejeteState extends State<ClientRejete> {
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
      await clientProvider
          .loadAllClients(); // Await the loading of clients.  CRUCIAL
      // Print the clients to the console
      print("Loaded clients in Valide: ${clientProvider.clients}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final rejectedClients =
        clientProvider.clients
            .where((q) => q.status == Client.statusRejected)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clients Rejetés"),
        backgroundColor: Colors.red,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body:
          rejectedClients.isEmpty
              ? const Center(child: Text("Aucun client rejeté pour le moment."))
              : ListView.builder(
                itemCount: rejectedClients.length,
                itemBuilder: (context, index) {
                  final client = rejectedClients[index];
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
                          if (client.commentaire != null &&
                              client.commentaire!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "Motif de rejet: ${client.commentaire}",
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.comment_bank_outlined,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          _showRejectDialog(context, clientProvider, client);
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Future<void> _showRejectDialog(
    BuildContext context,
    ClientProvider clientProvider,
    Client client,
  ) async {
    _rejectionReasonController.text = client.commentaire ?? '';

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Modifier le motif de rejet"),
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
                  if (_rejectionReasonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Le motif de rejet est obligatoire."),
                      ),
                    );
                    return;
                  }

                  await clientProvider.rejectClient(
                    client.id,
                    _rejectionReasonController.text.trim(),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Confirmer"),
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
