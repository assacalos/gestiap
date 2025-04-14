import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/views/pages/charge_form_page.dart';
import 'package:gestiap/features/comptable/views/providers/charges_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/comptable/data/models/charge_model.dart';
import 'package:intl/intl.dart';
// import 'package:gestiap/utils/depense_pdf_generator.dart'; // Si vous voulez un PDF des dépenses

class DepensesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Dépenses')),
      body: Consumer<DepenseProvider>(
        builder: (context, depenseProvider, child) {
          if (depenseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (depenseProvider.depenses.isEmpty) {
            return const Center(child: Text('Aucune dépense enregistrée.'));
          }
          return ListView.builder(
            itemCount: depenseProvider.depenses.length,
            itemBuilder: (context, index) {
              final depense = depenseProvider.depenses[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        depense.description,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(depense.date)}',
                      ),
                      Text('Montant: ${depense.montant.toStringAsFixed(2)}'),
                      Text('Catégorie: ${depense.categorie}'),
                      if (depense.fournisseurNom != null &&
                          depense.fournisseurNom!.isNotEmpty)
                        Text('Fournisseur: ${depense.fournisseurNom}'),
                      if (depense.reference != null &&
                          depense.reference!.isNotEmpty)
                        Text('Référence: ${depense.reference}'),
                      if (depense.methodePaiement != null &&
                          depense.methodePaiement!.isNotEmpty)
                        Text('Méthode de Paiement: ${depense.methodePaiement}'),
                      if (depense.pieceJustificativeUrl != null &&
                          depense.pieceJustificativeUrl!.isNotEmpty)
                        Text(
                          'Pièce Justificative: Lien disponible',
                        ), // Vous pouvez choisir d'afficher un aperçu ou un bouton de téléchargement
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DepenseFormPage(
                                        depenseToEdit: depense,
                                      ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              _deleteDepense(context, depense.id!);
                            },
                          ),
                          // Si vous voulez générer un PDF de la dépense
                          // IconButton(
                          //   icon: const Icon(Icons.picture_as_pdf),
                          //   onPressed: () {
                          //     // generateDepensePdf(depense);
                          //   },
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DepenseFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteDepense(BuildContext context, String depenseId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette dépense ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<DepenseProvider>(
                  context,
                  listen: false,
                ).deleteDepense(depenseId);
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
