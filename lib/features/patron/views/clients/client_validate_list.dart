import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';

class ClientsValide extends StatefulWidget {
  const ClientsValide({super.key});

  @override
  State<ClientsValide> createState() => _ClientsValideState();
}

class _ClientsValideState extends State<ClientsValide> {
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
    final validatedClients =
        clientProvider.clients
            .where((q) => q.status == Client.statusValidated)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clients Validés"),
        backgroundColor: Colors.green,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body:
          validatedClients
                  .isEmpty // Utilise validatedClients ici
              ? const Center(child: Text("Aucun client validé pour le moment."))
              : ListView.builder(
                itemCount:
                    validatedClients
                        .length, // Utilise validatedClients.length ici
                itemBuilder: (context, index) {
                  final client =
                      validatedClients[index]; // Utilise validatedClients[index] ici
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
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
