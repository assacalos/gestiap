import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/utils/Proforma_pdf_generator.dart';
import 'package:gestiap/features/commercial/views/pages/proforma_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/views/providers/proforma_provider.dart';
import 'package:gestiap/features/commercial/views/pages/proforma_form_page.dart';

class ListeProformaPage extends StatefulWidget {
  final String status;
  const ListeProformaPage({super.key, required this.status});
  @override
  _ListeProformaPageState createState() => _ListeProformaPageState();
  //ListeDevisPage({super.key, required this.status});
}

class _ListeProformaPageState extends State<ListeProformaPage> {
  int _currentPageIndex = 0; // Indice de la page actuelle pour la navigation
  String get status => widget.status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion des Proforma')),
      body: Consumer<QuoteProvider>(
        builder: (context, quoteProvider, child) {
          final filteredDevis =
              quoteProvider.quotes
                  .where(
                    (devis) =>
                        devis.status.toLowerCase() == status.toLowerCase(),
                  )
                  .toList();

          if (quoteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (filteredDevis.isEmpty) {
            return Center(child: Text('Aucun devis avec le statut "$status".'));
          } else {
            return ListView.builder(
              itemCount: filteredDevis.length,
              itemBuilder: (context, index) {
                final devis = filteredDevis[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Devis #${devis.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Client: ${devis.clientName}'),
                        Text('Date de création: ${devis.createdAt.toLocal()}'),
                        Text('Statut: ${devis.status}'),
                        // Ajoutez d'autres informations que vous souhaitez afficher
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bouton de génération de PDF (pour tous les statuts)
                        IconButton(
                          icon: Icon(Icons.picture_as_pdf, color: Colors.blue),
                          onPressed: () {
                            generateQuotePdf(devis);
                          },
                        ),
                        // Bouton d'édition (uniquement pour les devis non validés)
                        if (devis.status.toLowerCase() !=
                            QuoteModel.statusValidated.toLowerCase())
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          DevisFormPage(devisToEdit: devis),
                                ),
                              );
                            },
                          ),
                        // Bouton de suppression (uniquement pour les devis non validés)
                        if (devis.status.toLowerCase() !=
                            QuoteModel.statusValidated.toLowerCase())
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              _showDeleteConfirmationDialog(
                                context,
                                devis,
                                quoteProvider,
                              );
                            },
                          ),
                        // Bouton pour soumettre le devis (si le statut est brouillon)
                        if (devis.status.toLowerCase() ==
                            QuoteModel.statusDraft.toLowerCase())
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              _showConfirmationDialog(
                                context,
                                devis,
                                quoteProvider,
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
                              (context) => ProformaDetailsPage(proforma: devis),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
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
    QuoteModel devis,
    QuoteProvider quoteProvider,
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
                  'Êtes-vous sûr de vouloir supprimer le Proforma #${devis.id} ?',
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
                quoteProvider.deleteQuote(
                  devis.id,
                ); // Appel de la fonction de suppression
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proforma supprimé.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Fonction pour afficher une boîte de dialogue de confirmation avant la soumission
  Future<void> _showConfirmationDialog(
    BuildContext context,
    QuoteModel devis,
    QuoteProvider quoteProvider,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // L'utilisateur doit interagir avec la boîte de dialogue
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la soumission'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Êtes-vous sûr de vouloir soumettre le Proforma #${devis.id} ?',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(); // Fermer la boîte de dialogue
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text('Soumettre'),
              onPressed: () {
                quoteProvider.submitQuote(
                  devis.id,
                ); // Appeler la fonction de soumission
                Navigator.of(
                  dialogContext,
                ).pop(); // Fermer la boîte de dialogue
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proforma soumis !')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
