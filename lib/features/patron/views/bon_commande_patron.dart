import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/data/models/bon_commande.dart';
import 'package:gestiap/features/commercial/providers/bonCommandes/bon_commande_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/providers/bonCommandes/bon_commande_provider.dart';
import 'package:gestiap/features/commercial/data/models/bon_commande.dart';

class BonsDeCommandePatronPage extends StatefulWidget {
  const BonsDeCommandePatronPage({Key? key}) : super(key: key);

  @override
  State<BonsDeCommandePatronPage> createState() =>
      _BonsDeCommandePatronPageState();
}

class _BonsDeCommandePatronPageState extends State<BonsDeCommandePatronPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BonDeCommandeProvider>(
        context,
        listen: false,
      ).fetchBonsDeCommandePourPatron(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bonDeCommandeProvider = Provider.of<BonDeCommandeProvider>(context);
    final bonsSoumis =
        bonDeCommandeProvider.bonsDeCommande
            .where((b) => b.status == BonDeCommandeModel.statusSoumisPatron)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Bons de Commande (Patron)'),
      ),
      body:
          bonDeCommandeProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : bonsSoumis.isEmpty
              ? const Center(
                child: Text('Aucun bon de commande en attente de validation.'),
              )
              : ListView.builder(
                itemCount: bonsSoumis.length,
                itemBuilder: (context, index) {
                  final bonDeCommande = bonsSoumis[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bon de Commande #${bonDeCommande.id ?? 'N/A'}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text('Client ID: ${bonDeCommande.clientId}'),
                          Text('Acompte Reçu: ${bonDeCommande.acompteRecu}'),
                          Text(
                            'Date de Création: ${bonDeCommande.createdAt.toLocal().toString().split('.').first}',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed:
                                    () => _showRejectDialog(
                                      context,
                                      bonDeCommande.id!,
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Rejeter'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed:
                                    () => bonDeCommandeProvider
                                        .validerBonDeCommandeParPatron(
                                          bonDeCommande.id!,
                                        ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text('Valider'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  void _showRejectDialog(BuildContext context, String bonDeCommandeId) {
    final TextEditingController commentaireController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Rejeter le Bon de Commande'),
          content: TextField(
            controller: commentaireController,
            decoration: const InputDecoration(
              labelText: 'Commentaire de rejet (facultatif)',
            ),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<BonDeCommandeProvider>(
                  context,
                  listen: false,
                ).rejeterBonDeCommandeParPatron(
                  bonDeCommandeId,
                  commentaireController.text,
                );
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Rejeter'),
            ),
          ],
        );
      },
    );
  }
}
