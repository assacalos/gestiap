import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/technicien/providers/stock_provider.dart';
import 'package:gestiap/features/technicien/data/models/stock_model.dart';

class StockFormPage extends StatefulWidget {
  final StockItem?
  itemToEdit; // Le produit à éditer (peut être null pour l'ajout)

  const StockFormPage({super.key, this.itemToEdit});

  @override
  _StockFormPageState createState() => _StockFormPageState();
}

class _StockFormPageState extends State<StockFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeProduitController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixVenteController = TextEditingController();
  final _quantiteEntreeController = TextEditingController();
  final _prixAchatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pré-remplir les champs si nous sommes en mode édition
    if (widget.itemToEdit != null) {
      _codeProduitController.text = widget.itemToEdit!.codeProduit;
      _descriptionController.text = widget.itemToEdit!.description;
      _prixVenteController.text =
          widget.itemToEdit!.prixVenteUnitaire.toString();
      _quantiteEntreeController.text =
          widget.itemToEdit!.quantiteEntree.toString();
      _prixAchatController.text =
          widget.itemToEdit!.prixAchatUnitaire.toString();
    }
  }

  @override
  void dispose() {
    _codeProduitController.dispose();
    _descriptionController.dispose();
    _prixVenteController.dispose();
    _quantiteEntreeController.dispose();
    _prixAchatController.dispose();
    super.dispose();
  }

  void _saveOrUpdateStockItem(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final newItem = StockItem(
        id: widget.itemToEdit?.id ?? '', // Générer un nouvel ID si ajout
        codeProduit: _codeProduitController.text.trim(),
        description: _descriptionController.text.trim(),
        prixVenteUnitaire: double.tryParse(_prixVenteController.text) ?? 0.0,
        quantiteEntree: int.tryParse(_quantiteEntreeController.text) ?? 0,
        prixAchatUnitaire: double.tryParse(_prixAchatController.text) ?? 0.0,
        dateAjout: widget.itemToEdit?.dateAjout, // Conserver la date d'ajout
        quantiteEnStock:
            widget.itemToEdit?.quantiteEnStock ??
            _quantiteEntreeController.text
                .trim(), // Initialiser le stock à l'entrée
      );

      if (widget.itemToEdit == null) {
        Provider.of<StockProvider>(
          context,
          listen: false,
        ).addStockItem(newItem);
      } else {
        Provider.of<StockProvider>(
          context,
          listen: false,
        ).updateStockItem(newItem);
      }
      Navigator.pop(context); // Retour à la liste après l'ajout/modification
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.itemToEdit == null
              ? 'Ajouter un Produit au Stock'
              : 'Modifier l\'Article',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _codeProduitController,
                decoration: const InputDecoration(labelText: 'Code Produit'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le code produit';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prixVenteController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Prix Vente Unitaire',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prix de vente';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantiteEntreeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantité Entrée'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la quantité';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre entier valide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prixAchatController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Prix Achat Unitaire',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prix d\'achat';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _saveOrUpdateStockItem(context),
                child: Text(
                  widget.itemToEdit == null ? 'Enregistrer' : 'Mettre à jour',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
