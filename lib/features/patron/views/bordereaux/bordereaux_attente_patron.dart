import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/providers/bordereaux/bordereaux_provider.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux/bordereaux_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';
// Importez le fichier de polices

class PendingBordereauxList extends StatelessWidget {
  const PendingBordereauxList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bordereaux en Attente',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ), // Applique la police Poppins
        ),
        centerTitle: true,
        backgroundColor: Colors.blue, // Couleur унифицированную de l'app bar
        elevation: 0,
      ),
      body: Consumer<BordereauxProvider>(
        builder: (context, bordereauxProvider, child) {
          final pendingBordereaux =
              bordereauxProvider.bordereaux
                  .where(
                    (b) => b.status == BordereauModel.statusPendingValidation,
                  )
                  .toList();

          if (bordereauxProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ), // Couleur унифицированную de l'indicateur de chargement
            );
          }

          if (pendingBordereaux.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Aucun bordereau en attente de validation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto', // Applique la police Roboto
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: pendingBordereaux.length,
            itemBuilder: (context, index) {
              final bordereau = pendingBordereaux[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ), // Espacement horizontal accru
                elevation: 6, // Légère augmentation de l'élévation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Bords arrondis pour les cartes
                ),
                child: InkWell(
                  // Utilisation de InkWell pour l'effet ripple au clic
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                BordereauDetailsPage(bordereau: bordereau),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ), // Espacement à l'intérieur de InkWell
                    child: Row(
                      // Utilisation de Row pour une meilleure disposition
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bordereau # ${bordereau.id} - ${bordereau.clientName}',
                                style: TextStyle(
                                  fontFamily: 'Roboto', // Appliquer Roboto
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Colors
                                          .blue[800], // Utiliser une teinte plus foncée
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Soumis le: ${bordereau.createdAt.toLocal()}',
                                style: TextStyle(
                                  fontFamily: 'Roboto', // Appliquer Roboto
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          // Déplacement des boutons d'action dans une ligne séparée
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                Provider.of<BordereauxProvider>(
                                  context,
                                  listen: false,
                                ).validateBordereau(bordereau.id, context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => _buildRejectDialog(
                                        context,
                                        bordereau,
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Extraction de la construction de la boîte de dialogue dans une méthode séparée
  AlertDialog _buildRejectDialog(
    BuildContext context,
    BordereauModel bordereau,
  ) {
    final rejectionCommentController =
        TextEditingController(); // Ajout d'un contrôleur

    return AlertDialog(
      title: const Text(
        'Rejeter le bordereau',
        style: TextStyle(fontFamily: 'Poppins'),
      ),
      content: TextField(
        controller: rejectionCommentController, // Utilisation du contrôleur ici
        decoration: const InputDecoration(
          labelText: 'Motif du rejet',
          labelStyle: TextStyle(fontFamily: 'Roboto'),
        ),
        style: const TextStyle(fontFamily: 'Roboto'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler', style: TextStyle(fontFamily: 'Roboto')),
        ),
        TextButton(
          onPressed: () {
            final comment = rejectionCommentController.text.trim();
            if (comment.isNotEmpty) {
              Provider.of<BordereauxProvider>(
                context,
                listen: false,
              ).rejectBordereau(bordereau.id, comment, context);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Rejeter', style: TextStyle(fontFamily: 'Roboto')),
        ),
      ],
    );
  }
}
