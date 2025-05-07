import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/views/pages/fournisseurs/fournisseurs_form_page.dart';
import 'package:gestiap/features/comptable/providers/fournisseurs_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/comptable/data/models/fournisseurs_model.dart';

// import 'package:gestiap/utils/fournisseur_pdf_generator.dart'; // Si vous voulez un PDF des infos du fournisseur

class FournisseursPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Fournisseurs')),
      body: Consumer<FournisseurProvider>(
        builder: (context, fournisseurProvider, child) {
          if (fournisseurProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (fournisseurProvider.fournisseurs.isEmpty) {
            return const Center(child: Text('Aucun fournisseur disponible.'));
          }
          return ListView.builder(
            itemCount: fournisseurProvider.fournisseurs.length,
            itemBuilder: (context, index) {
              final fournisseur = fournisseurProvider.fournisseurs[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fournisseur.nom,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (fournisseur.entreprise != null &&
                          fournisseur.entreprise!.isNotEmpty)
                        Text('Entreprise: ${fournisseur.entreprise}'),
                      if (fournisseur.adresse != null &&
                          fournisseur.adresse!.isNotEmpty)
                        Text('Adresse: ${fournisseur.adresse}'),
                      if (fournisseur.contact != null &&
                          fournisseur.contact!.isNotEmpty)
                        Text('Contact: ${fournisseur.contact}'),
                      if (fournisseur.email != null &&
                          fournisseur.email!.isNotEmpty)
                        Text('Email: ${fournisseur.email}'),
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
                                      (context) => FournisseurFormPage(
                                        fournisseurToEdit: fournisseur,
                                      ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              _deleteFournisseur(context, fournisseur.id!);
                            },
                          ),
                          // Si vous voulez générer un PDF des infos du fournisseur
                          // IconButton(
                          //   icon: const Icon(Icons.picture_as_pdf),
                          //   onPressed: () {
                          //     // generateFournisseurPdf(fournisseur);
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
            MaterialPageRoute(builder: (context) => FournisseurFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteFournisseur(BuildContext context, String fournisseurId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce fournisseur ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<FournisseurProvider>(
                  context,
                  listen: false,
                ).deleteFournisseur(fournisseurId);
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
