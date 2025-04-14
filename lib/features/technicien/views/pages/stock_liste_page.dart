import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/technicien/views/providers/stock_provider.dart';
import 'package:gestiap/features/technicien/data/models/stock_model.dart';
import 'package:gestiap/features/technicien/views/pages/stock_form_page.dart';
import 'package:gestiap/features/technicien/utils/stock_pdf_generator.dart';

class StockListPage extends StatelessWidget {
  const StockListPage({super.key});
  StockProvider get stockProvider => StockProvider();
  StockItem? get stockItem => null;

  void _deleteStockItem(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cet article du stock ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<StockProvider>(
                  context,
                  listen: false,
                ).deleteStockItem(itemId);
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

  void _generatePdf(BuildContext context, StockItem item) {
    // TODO: Implémenter la logique de génération de PDF ici
    // Vous aurez probablement besoin d'un package comme `pdf` ou `printing`.
    // Cette fonction devrait prendre l'objet StockItem et créer un document PDF.
    generateStockItemPdf(item);
    print('Générer PDF pour : ${item.codeProduit}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fonctionnalité PDF non implémentée pour ${item.codeProduit}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Stocks')),
      body: Consumer<StockProvider>(
        builder: (context, stockProvider, child) {
          if (stockProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (stockProvider.stockItems.isEmpty) {
            return const Center(child: Text('Aucun produit en stock.'));
          }
          return ListView.builder(
            itemCount: stockProvider.stockItems.length,
            itemBuilder: (context, index) {
              final item = stockProvider.stockItems[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.codeProduit} - ${item.description}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Prix Vente: ${item.prixVenteUnitaire}'),
                      Text('Quantité: ${item.quantiteEntree}'),
                      Text('Prix Achat: ${item.prixAchatUnitaire}'),
                      Text('Ajouté le: ${item.dateAjout.toLocal()}'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _generatePdf(context, item),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('PDF'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => StockFormPage(
                                        itemToEdit: item,
                                      ), // Passez l'item à éditer
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Modifier'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed:
                                () => _deleteStockItem(context, item.id!),
                            icon: const Icon(Icons.delete),
                            label: const Text('Supprimer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                          ),
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
            MaterialPageRoute(
              builder: (context) => const StockFormPage(),
            ), // Pas d'itemToEdit pour l'ajout
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
