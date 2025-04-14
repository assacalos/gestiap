import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/views/providers/bordereaux_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart'; // Assurez-vous que le chemin est correct
import 'package:gestiap/features/commercial/views/providers/bordereaux_provider.dart'; // Assurez-vous que le chemin est correct
import 'package:gestiap/features/commercial/utils/bordereaux_pdf_generator.dart'; // Créez ce fichier utilitaire
import 'package:gestiap/features/commercial/views/pages/bordereaux_detail_page.dart'; // Créez cette page de détails
import 'package:gestiap/features/commercial/views/pages/bordereaux_form.dart'; // Créez cette page de formulaire
import 'package:open_file/open_file.dart';

class ListeBordereauxPage extends StatefulWidget {
  final String status;
  const ListeBordereauxPage({super.key, required this.status});
  @override
  _ListeBordereauxPageState createState() => _ListeBordereauxPageState();
}

class _ListeBordereauxPageState extends State<ListeBordereauxPage> {
  int _currentPageIndex = 0; // Indice de la page actuelle pour la navigation
  String get status => widget.status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion des bordereaux')),
      body: Consumer<BordereauxProvider>(
        // Utilisez votre BordereauProvider
        builder: (context, bordereauProvider, child) {
          final filteredBordereaux =
              bordereauProvider
                  .bordereaux // Utilisez la liste de bordereaux
                  .where(
                    (bordereau) =>
                        bordereau.status.toLowerCase() == status.toLowerCase(),
                  )
                  .toList();

          if (bordereauProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (filteredBordereaux.isEmpty) {
            return Center(
              child: Text('Aucun bordereau avec le statut "$status".'),
            );
          } else {
            return ListView.builder(
              itemCount: filteredBordereaux.length,
              itemBuilder: (context, index) {
                final bordereau = filteredBordereaux[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Bordereau #${bordereau.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Référence: ${bordereau.id}',
                        ), // Remplacez par les propriétés de votre modèle
                        Text(
                          'Date de création: ${bordereau.createdAt.toLocal()}',
                        ),
                        Text('Statut: ${bordereau.status}'),
                        // Ajoutez d'autres informations que vous souhaitez afficher
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bouton de génération de PDF
                        IconButton(
                          icon: Icon(Icons.picture_as_pdf, color: Colors.blue),
                          onPressed: () async {
                            final pdfFile =
                                await BordereauPdfGenerator.generatePdf(
                                  bordereau,
                                );
                            // Optionnel : Ouvrir le fichier PDF après la génération
                            OpenFile.open(
                              pdfFile.path,
                            ); // Utilisez la fonction PDF pour les bordereaux
                          },
                        ),
                        // Bouton d'édition (adaptez la condition et la page de formulaire)
                        if (bordereau.status.toLowerCase() !=
                            BordereauModel.statusValidated
                                .toLowerCase()) // Utilisez les statuts de votre modèle
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => BordereauFormPage(
                                        bordereauToEdit: bordereau,
                                      ), // Utilisez la page de formulaire des bordereaux
                                ),
                              );
                            },
                          ),
                        // Bouton de suppression
                        if (bordereau.status.toLowerCase() !=
                            BordereauModel.statusValidated.toLowerCase())
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              _showDeleteConfirmationDialog(
                                context,
                                bordereau,
                                Provider.of<BordereauxProvider>(
                                  context,
                                  listen: false,
                                ), // Utilisez votre BordereauProvider
                              );
                            },
                          ),
                        // Ajoutez d'autres boutons spécifiques aux bordereaux si nécessaire
                        // Bouton pour soumettre le devis (si le statut est brouillon)
                        // Bouton pour soumettre le bordereau (si le statut est brouillon)
                        if (bordereau.status.toLowerCase() ==
                            BordereauModel.statusDraft.toLowerCase())
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              _showConfirmationDialog(
                                context,
                                bordereau,
                                Provider.of<BordereauxProvider>(
                                  context,
                                  listen: false,
                                ),
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
                              (context) => BordereauDetailsPage(
                                bordereau: bordereau,
                              ), // Utilisez la page de détails des bordereaux
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
    BordereauModel bordereau,
    BordereauxProvider bordereauProvider,
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
                  'Êtes-vous sûr de vouloir supprimer le bordereau #${bordereau.id} ?',
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
                bordereauProvider.deleteBordereau(
                  bordereau.id,
                ); // Utilisez la fonction de suppression de votre provider
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bordereau supprimé.')),
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
    BordereauModel bordereau,
    BordereauxProvider bordereauxProvider,
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
                  'Êtes-vous sûr de vouloir soumettre le bordereau #${bordereau.id} ?',
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
                bordereauxProvider.submitBordereau(
                  bordereau.id,
                ); // Appeler la fonction de soumission de votre provider
                Navigator.of(
                  dialogContext,
                ).pop(); // Fermer la boîte de dialogue
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bordereau soumis !')),
                );
                Navigator.pop(
                  context,
                ); // Retour à la page précédente après soumission
              },
            ),
          ],
        );
      },
    );
  }

  // Ajoutez ici d'autres fonctions de confirmation spécifiques aux bordereaux si nécessaire
}
