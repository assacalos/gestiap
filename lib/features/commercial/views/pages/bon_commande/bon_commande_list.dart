import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/providers/bonCommandes/bon_commande_provider.dart';
import 'package:gestiap/features/commercial/data/models/bon_commande.dart';
import 'package:gestiap/features/commercial/views/pages/bon_commande/bon_commande_form.dart';

class BonsDeCommandeListPage extends StatefulWidget {
  const BonsDeCommandeListPage({Key? key}) : super(key: key);

  @override
  State<BonsDeCommandeListPage> createState() => _BonsDeCommandeListPageState();
}

class _BonsDeCommandeListPageState extends State<BonsDeCommandeListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BonDeCommandeProvider>(
        context,
        listen: false,
      ).fetchBonsDeCommande(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bonDeCommandeProvider = Provider.of<BonDeCommandeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Bons de Commande')),
      body:
          bonDeCommandeProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: bonDeCommandeProvider.bonsDeCommande.length,
                itemBuilder: (context, index) {
                  final bonDeCommande =
                      bonDeCommandeProvider.bonsDeCommande[index];
                  return ListTile(
                    title: Text(
                      'Bon de Commande #${bonDeCommande.id ?? 'N/A'}',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Client ID: ${bonDeCommande.clientId}'),
                        Text('Acompte Reçu: ${bonDeCommande.acompteRecu}'),
                        Text('Statut: ${bonDeCommande.status}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => BonDeCommandeFormPage(
                                      bonDeCommandeToEdit: bonDeCommande,
                                    ),
                              ),
                            );
                          },
                        ),
                        // Ajoutez d'autres actions si nécessaire (supprimer, afficher les détails, etc.)
                      ],
                    ),
                    onTap: () {
                      // TODO: Afficher les détails du bon de commande
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BonDeCommandeFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
