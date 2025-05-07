import 'package:flutter/material.dart';
import 'package:gestiap/features/technicien/data/models/stock_model.dart';
import 'package:gestiap/features/technicien/providers/stock_provider.dart';
import 'package:provider/provider.dart';

import 'package:gestiap/core/widgets/widgets_widgets.dart'; //Pour les CustomBottomNavigationBar

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  int _currentPageIndex = 0; // Pour gérer l'index de la page actuelle
  // Pas besoin d'un ChangeNotifierProvider ici, il doit être au-dessus dans l'arbre des widgets
  @override
  void initState() {
    super.initState();
    // La logique d'initialisation du provider doit être dans le main.dart ou un parent
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    stockProvider
        .fetchStockItems(); // Charger le stock au démarrage de la page.
  }

  @override
  Widget build(BuildContext context) {
    // Consolider l'accès au StockProvider
    final stockProvider = Provider.of<StockProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion du Stock'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Utilisation d'une Column pour organiser les éléments de la page
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Liste des Produits en Stock',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Affichage de la liste des stocks
            Expanded(
              // Utilisation de Expanded pour que la ListView occupe l'espace restant
              child: _buildStockList(stockProvider),
            ),
            const SizedBox(height: 20),
            //Bouton d'ajout de produit au stock
            ElevatedButton(
              onPressed: () {
                _showAddStockDialog(context, stockProvider);
              },
              child: const Text('Ajouter un produit au stock'),
            ),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNavigationBar(
        onTabChange: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        initialIndex: _currentPageIndex,
      ),
      // Assurez-vous que CustomBottomNavigationBar est correctement défini
    );
  }

  // Méthode pour construire la liste des stocks
  Widget _buildStockList(StockProvider stockProvider) {
    if (stockProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Afficher un loader pendant le chargement
    } else if (stockProvider.stockItems.isEmpty) {
      return const Center(
        child: Text('Aucun produit en stock trouvé.'),
      ); // Message si la liste est vide.
    } else {
      return ListView.builder(
        itemCount: stockProvider.stockItems.length,
        itemBuilder: (context, index) {
          final StockItem stockItem = stockProvider.stockItems[index];
          return _buildStockListItem(stockItem, stockProvider);
        },
      );
    }
  }

  // Méthode pour construire chaque élément de la liste
  Widget _buildStockListItem(StockItem stockItem, StockProvider stockProvider) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${stockItem.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Produit: ${stockItem.codeProduit}'),
                Text('Quantité: ${stockItem.quantiteEntree}'),
                Text('Description: ${stockItem.description}'),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditStockDialog(
                      context,
                      stockItem,
                      stockProvider,
                    ); // Passer le stockItem à éditer
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteStockDialog(
                      context,
                      stockItem.id,
                      stockProvider,
                    ); // Passer l'ID du stockItem à supprimer
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour afficher la boîte de dialogue d'ajout de produit au stock
  void _showAddStockDialog(BuildContext context, StockProvider stockProvider) {
    final _formKey = GlobalKey<FormState>();
    String produit = '';
    int quantite = 0;
    String description = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un produit au stock'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Produit'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le nom du produit';
                      }
                      return null;
                    },
                    onSaved: (value) => produit = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Quantité'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer la quantité';
                      }
                      final n = int.tryParse(value);
                      if (n == null) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      if (n <= 0) {
                        return 'La quantité doit être supérieure à zéro';
                      }
                      return null;
                    },
                    onSaved: (value) => quantite = int.parse(value!),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer la description';
                      }
                      return null;
                    },
                    onSaved: (value) => description = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newStockItem = StockItem(
                    id: DateTime.now().toString(), // Générer un ID unique
                    codeProduit: produit,
                    quantiteEntree: quantite,
                    description: description,
                    prixVenteUnitaire: 0.0, // Valeur par défaut
                    prixAchatUnitaire: 0.0, // Valeur par défaut
                  );
                  stockProvider.addStockItem(
                    newStockItem,
                  ); // Utiliser la méthode du provider
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produit ajouté au stock avec succès!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour afficher la boîte de dialogue de modification de produit en stock
  void _showEditStockDialog(
    BuildContext context,
    StockItem stockItemAModifier,
    StockProvider stockProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    String produit = stockItemAModifier.codeProduit;
    int quantite = stockItemAModifier.quantiteEntree;
    String description = stockItemAModifier.description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier un produit en stock'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: stockItemAModifier.codeProduit,
                    decoration: const InputDecoration(labelText: 'Produit'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le nom du produit';
                      }
                      return null;
                    },
                    onSaved: (value) => produit = value!,
                  ),
                  TextFormField(
                    initialValue: stockItemAModifier.quantiteEntree.toString(),
                    decoration: const InputDecoration(labelText: 'Quantité'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer la quantité';
                      }
                      final n = int.tryParse(value);
                      if (n == null) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      if (n <= 0) {
                        return 'La quantité doit être supérieure à zéro';
                      }
                      return null;
                    },
                    onSaved: (value) => quantite = int.parse(value!),
                  ),
                  TextFormField(
                    initialValue: stockItemAModifier.description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer la description';
                      }
                      return null;
                    },
                    onSaved: (value) => description = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Mettre à jour le stock
                  final updatedStockItem = StockItem(
                    id:
                        stockItemAModifier
                            .id, // Garder le même ID du stockItem.
                    codeProduit: produit,
                    quantiteEntree: quantite,
                    description: description,
                    prixAchatUnitaire: stockItemAModifier.prixAchatUnitaire,
                    prixVenteUnitaire: stockItemAModifier.prixVenteUnitaire,
                  );
                  stockProvider.updateStockItem(
                    updatedStockItem,
                  ); // Utiliser la méthode update du provider

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produit en stock modifié avec succès!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour afficher la boîte de dialogue de confirmation de suppression
  void _showDeleteStockDialog(
    BuildContext context,
    String stockItemId,
    StockProvider stockProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer un produit du stock'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce produit du stock ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                stockProvider.deleteStockItem(
                  stockItemId,
                ); // Utiliser la méthode delete du provider
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produit supprimé du stock avec succès!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
