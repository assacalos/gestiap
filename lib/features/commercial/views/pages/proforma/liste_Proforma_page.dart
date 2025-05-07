import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/utils/Proforma_pdf_generator.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/proforma_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:gestiap/features/commercial/views/pages/proforma/proforma_form_page.dart';

class ListeProformaPage extends StatefulWidget {
  final String status;
  final List<QuoteModel> devis; // Les devis sont maintenant passés en paramètre

  const ListeProformaPage({Key? key, required this.status, required this.devis})
    : super(key: key); // Ajout de Key? key
  @override
  _ListeProformaPageState createState() => _ListeProformaPageState();
}

class _ListeProformaPageState extends State<ListeProformaPage> {
  int _currentPageIndex = 0; // Indice de la page actuelle pour la navigation
  String get status => widget.status;
  List<QuoteModel> _filteredDevis =
      []; // Stocker la liste filtrée dans l'état local

  @override
  void initState() {
    super.initState();
    _filterDevis(); // Filtrer les devis lors de l'initialisation
  }

  @override
  void didUpdateWidget(ListeProformaPage oldWidget) {
    // Important pour les mises à jour
    super.didUpdateWidget(oldWidget);
    if (oldWidget.devis != widget.devis ||
        oldWidget.status !=
            widget
                .status) // Refiltrer si la liste des devis ou le statut change
    {
      _filterDevis();
    }
  }

  void _filterDevis() {
    // Méthode pour filtrer les devis
    _filteredDevis =
        widget.devis
            .where(
              (devis) => devis.status.toLowerCase() == status.toLowerCase(),
            )
            .toList();
    if (mounted) {
      setState(
        () {},
      ); // Mettre à jour l'état pour reconstruire l'interface utilisateur
    }
  }

  @override
  Widget build(BuildContext context) {
    final quoteProvider = Provider.of<QuoteProvider>(context);
    // N'utilisez plus la liste directement depuis le provider ici.
    // Utilisez _filteredDevis.

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Proforma')),
      body:
          // Affichez un message de chargement si nécessaire (bien que les données soient déjà chargées)
          quoteProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredDevis.isEmpty
              ? Center(child: Text('Aucun devis avec le statut "$status".'))
              : ListView.builder(
                itemCount: _filteredDevis.length,
                itemBuilder: (context, index) {
                  final devis = _filteredDevis[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Devis #${devis.id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Client: ${devis.clientName}'),
                          Text(
                            'Date de création: ${devis.createdAt.toLocal()}',
                          ),
                          Text('Statut: ${devis.status}'),
                          // Ajoutez d'autres informations que vous souhaitez afficher
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bouton de génération de PDF (uniquement pour les devis validés)
                          if (devis.status.toLowerCase() ==
                              QuoteModel.statusValidated.toLowerCase())
                            IconButton(
                              icon: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                generateQuotePdf(devis);
                              },
                            ),
                          // Bouton d'édition (uniquement pour les devis rejetés)
                          if (devis.status.toLowerCase() ==
                              QuoteModel.statusRejected.toLowerCase())
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
                          // Bouton de suppression (pour tous les statuts sauf Validé et Rejeté)
                          if (devis.status.toLowerCase() !=
                                  QuoteModel.statusValidated.toLowerCase() &&
                              devis.status.toLowerCase() !=
                                  QuoteModel.statusRejected.toLowerCase())
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
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ProformaDetailsPage(proforma: devis),
                          ),
                        );
                      },
                    ),
                  );
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
}
