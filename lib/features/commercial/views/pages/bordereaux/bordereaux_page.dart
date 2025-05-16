import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import 'bordereaux_form.dart'; // Assurez-vous que le chemin est correct
import 'package:gestiap/features/commercial/utils/bordereaux_pdf_generator.dart'; // Assurez-vous que le chemin est correct
import 'package:gestiap/features/commercial/providers/bordereaux/bordereaux_provider.dart'; // Assurez-vous que le chemin est correct
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart'; // Assurez-vous que le chemin est correct

class BordereauxPage extends StatefulWidget {
  const BordereauxPage({Key? key}) : super(key: key); // Utilisez Key?

  @override
  _BordereauxPageState createState() => _BordereauxPageState();
}

class _BordereauxPageState extends State<BordereauxPage> {
  String searchQuery = '';
  late BordereauxProvider bordereauxProvider; // Déclarez le provider ici

  @override
  void initState() {
    super.initState();
    // Utilisez didChangeDependencies pour accéder au context après l'initialisation.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bordereauxProvider = Provider.of<BordereauxProvider>(
      context,
      listen: false,
    );
    // Initialisez le provider ici, dans didChangeDependencies
    if (bordereauxProvider.bordereaux.isEmpty) {
      bordereauxProvider.loadBordereaux(
        context,
      ); // Charger les données une seule fois
    }
  }

  Future<void> _generateAndShowPdf(
    BuildContext context,
    BordereauModel bordereau,
  ) async {
    try {
      // Récupérer les octets du PDF
      final pdfBytes = await BordereauPdfGenerator.generatePdf(bordereau);

      // Créer un fichier temporaire pour stocker le PDF
      final outputDir = await getTemporaryDirectory();
      final filePath = '${outputDir.path}/bordereau_${bordereau.id}.pdf';
      final file = File(filePath);

      // Écrire les octets dans le fichier
      await file.writeAsBytes(pdfBytes);

      // Afficher une notification de succès
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF généré : ${file.path}')));

      // Ouvrir le fichier PDF
      await OpenFile.open(file.path);
    } catch (e) {
      // Gestion des erreurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la génération du PDF: $e')),
      );
      print('Error generating PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bordereaux de Livraison'),
        actions: [
          // Bouton PDF global
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // Accédez au provider via la variable
              if (bordereauxProvider.bordereaux.isNotEmpty) {
                _generateAndShowPdf(
                  context,
                  bordereauxProvider.bordereaux.first,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aucun bordereau à générer')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Recherche par client ou titre',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() => searchQuery = query.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: Consumer<BordereauxProvider>(
              builder: (context, provider, _) {
                // Filtrer les bordereaux directement ici.
                final filteredBordereaux =
                    provider.bordereaux.where((bordereau) {
                      final intitule = bordereau.intitule.toLowerCase();
                      final clientName =
                          bordereau.clientEntreprise.toLowerCase();
                      return intitule.contains(searchQuery) ||
                          clientName.contains(searchQuery);
                    }).toList();

                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (filteredBordereaux.isEmpty) {
                  return const Center(child: Text('Aucun bordereau trouvé.'));
                }

                return _buildGroupedList(
                  filteredBordereaux,
                ); // Utilisez la méthode renommée
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BordereauFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupedList(List<BordereauModel> bordereaux) {
    // Groupement des bordereaux par client et mois
    final Map<String, List<BordereauModel>> grouped = {};
    for (var bordereau in bordereaux) {
      final key =
          "${bordereau.clientEntreprise} - ${bordereau.dateLivraison.month}/${bordereau.dateLivraison.year}";
      grouped.putIfAbsent(key, () => []).add(bordereau);
    }

    return ListView(
      children:
          grouped.entries.map((entry) {
            return _buildExpansionTile(
              entry.key,
              entry.value,
            ); // Méthode pour construire l'ExpansionTile
          }).toList(),
    );
  }

  Widget _buildExpansionTile(String title, List<BordereauModel> bordereaux) {
    return ExpansionTile(
      title: Text(title),
      children:
          bordereaux.map((bordereau) {
            return _buildCardForBordereau(
              bordereau,
            ); // Méthode pour construire la Card
          }).toList(),
    );
  }

  Widget _buildCardForBordereau(BordereauModel bordereau) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(bordereau.intitule),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client : ${bordereau.clientEntreprise}'),
            Text('Livraison : ${bordereau.dateLivraison.toLocal()}'),
            Text('Articles : ${bordereau.articles.length}'),
            Text('État : ${bordereau.etatLivraison}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () => _generateAndShowPdf(context, bordereau),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => BordereauFormPage(bordereauToEdit: bordereau),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                // Confirmation avant de supprimer
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Confirmation'),
                        content: const Text(
                          'Êtes-vous sûr de vouloir supprimer ce bordereau ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                );
                if (confirm == true) {
                  try {
                    await bordereauxProvider.deleteBordereau(
                      bordereau.id,
                      context,
                    );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Supprimé')));
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
