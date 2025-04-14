import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/views/providers/bordereaux_provider.dart';
import 'package:provider/provider.dart';
import 'bordereaux_form.dart';
import 'package:gestiap/features/commercial/utils/bordereaux_pdf_generator.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/views/pages/bordereaux_form.dart';
import 'package:open_file/open_file.dart';

class BordereauxPage extends StatefulWidget {
  const BordereauxPage({super.key});

  @override
  State<BordereauxPage> createState() => _BordereauxPageState();
}

class _BordereauxPageState extends State<BordereauxPage> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BordereauxProvider>(context, listen: false).initialize();
    });
  }

  Future<void> _generateAndShowPdf(
    BuildContext context,
    BordereauModel bordereau,
  ) async {
    final file = await BordereauPdfGenerator.generatePdf(bordereau);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('PDF généré : ${file.path}')));
    // Tu peux aussi ouvrir le PDF ici avec open_file si tu veux
    await OpenFile.open(file.path);
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
              final provider = Provider.of<BordereauxProvider>(
                context,
                listen: false,
              );
              if (provider.bordereaux.isNotEmpty) {
                _generateAndShowPdf(context, provider.bordereaux.first);
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
                // Filtrer les bordereaux
                final filtered =
                    provider.bordereaux.where((b) {
                      return b.intitule.toLowerCase().contains(searchQuery) ||
                          b.clientName.toLowerCase().contains(searchQuery);
                    }).toList();

                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (filtered.isEmpty) {
                  return const Center(child: Text('Aucun bordereau trouvé.'));
                }

                return _groupedList(filtered);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BordereauFormPage()),
            ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _groupedList(List<BordereauModel> bordereaux) {
    // Groupement des bordereaux par client ou mois
    Map<String, List<BordereauModel>> grouped = {};

    for (var b in bordereaux) {
      final key =
          "${b.clientName} - ${b.dateLivraison.month}/${b.dateLivraison.year}";
      grouped.putIfAbsent(key, () => []).add(b);
    }

    return ListView(
      children:
          grouped.entries.map((entry) {
            return ExpansionTile(
              title: Text(entry.key),
              children:
                  entry.value.map((bordereau) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(bordereau.intitule),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Client : ${bordereau.clientName}'),
                            Text(
                              'Livraison : ${bordereau.dateLivraison.toLocal()}',
                            ),
                            Text('Articles : ${bordereau.articles.length}'),
                            Text('État : ${bordereau.etatLivraison}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf),
                              onPressed:
                                  () => _generateAndShowPdf(context, bordereau),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => BordereauFormPage(
                                          bordereauToEdit: bordereau,
                                        ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await Provider.of<BordereauxProvider>(
                                  context,
                                  listen: false,
                                ).deleteBordereau(bordereau.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Supprimé')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            );
          }).toList(),
    );
  }
}
