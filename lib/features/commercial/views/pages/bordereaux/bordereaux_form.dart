import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/utils/bordereaux_pdf_generator.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';

import 'package:intl/intl.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/providers/bordereaux/bordereaux_provider.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';

class BordereauFormPage extends StatefulWidget {
  final BordereauModel? bordereauToEdit;
  const BordereauFormPage({super.key, this.bordereauToEdit});

  @override
  State<BordereauFormPage> createState() => _BordereauFormPageState();
}

class _BordereauFormPageState extends State<BordereauFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClientId;
  String? _selectedQuoteId;
  String _deliveryStatus = "Livré";
  String _warrantyDelay = "3 mois";
  DateTime _deliveryDate = DateTime.now();
  late String bordereauId;
  late bool isEditing;
  List<ArticleLivraison> _items = [];
  final TextEditingController _intituleController = TextEditingController();
  String? _selectedCommercialId;
  List<Client> _clients = [];
  List<QuoteModel> _quotes = [];
  bool _isLoading = true; // Ajout d'un indicateur de chargement

  @override
  void initState() {
    super.initState();
    isEditing = widget.bordereauToEdit != null;
    bordereauId =
        widget.bordereauToEdit?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    if (isEditing) {
      final bordereau = widget.bordereauToEdit!;
      _selectedClientId = bordereau.clientId;
      _selectedQuoteId = bordereau.devisId;
      _deliveryStatus = bordereau.etatLivraison;
      _warrantyDelay = bordereau.delaiGarantie;
      _deliveryDate = bordereau.dateLivraison;
      _intituleController.text = bordereau.intitule;
      _items = List.from(bordereau.articles);
      _selectedCommercialId = bordereau.commercialId;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      final provider = Provider.of<BordereauxProvider>(context, listen: false);
      try {
        // Fetch clients and quotes and await
        await provider.clientProvider.getClients();
        await provider.quoteProvider.loadQuotes();
        //assign to local variables
        _clients = provider.clientProvider.clients;
        _quotes = provider.quoteProvider.quotes;
      } catch (e) {
        // Gérer les erreurs (par exemple, afficher un message à l'utilisateur)
        print("Error loading data: $e"); // Important : Log l'erreur
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load data: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading =
                false; // Mettre à jour l'état une fois le chargement terminé
          });
        }
      }
    }
  }

  List<QuoteModel> get _filteredQuotes {
    if (_selectedClientId == null) return [];
    return _quotes
        .where(
          (q) =>
              q.clientId == _selectedClientId &&
              q.status.toLowerCase() == 'validé',
        )
        .toList();
  }

  BordereauModel? _getCurrentBordereauFromForm() {
    if (_formKey.currentState!.validate() &&
        _selectedClientId != null &&
        _selectedQuoteId != null &&
        _selectedCommercialId != null) {
      final client = _clients.firstWhere((c) => c.id == _selectedClientId);
      final quote = _quotes.firstWhere((q) => q.id == _selectedQuoteId);

      return BordereauModel(
        id: bordereauId,
        clientId: client.id,
        clientName: client.nom,
        clientAdresse: client.adresse,
        commercialId: _selectedCommercialId!,
        commentaire: _intituleController.text,
        clientEmail: client.email,
        clientContact: client.telephone,
        devisId: quote.id,
        intitule: _intituleController.text,
        createdAt:
            isEditing ? widget.bordereauToEdit!.createdAt : DateTime.now(),
        dateLivraison: _deliveryDate,
        etatLivraison: _deliveryStatus,
        delaiGarantie: _warrantyDelay,
        articles: List.from(
          quote.items.map(
            (item) => ArticleLivraison(
              ref: item.ref,
              description: item.description,
              quantity: item.quantity,
              status: BordereauModel.statusPendingValidation,
            ),
          ),
        ),
        status:
            isEditing
                ? widget.bordereauToEdit!.status
                : BordereauModel.statusPendingValidation,
      );
    }
    return null;
  }

  Future<void> _showConfirmationDialog(
    BuildContext context,
    BordereauModel bordereau,
    BordereauxProvider bordereauxProvider,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text('Soumettre'),
              onPressed: () {
                bordereauxProvider.addBordereau(bordereau, context);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bordereau soumis !')),
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BordereauxProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Modifier un Bordereau" : "Créer un Bordereau"),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                final currentBordereau = _getCurrentBordereauFromForm();
                if (currentBordereau != null) {
                  _showConfirmationDialog(context, currentBordereau, provider);
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(),
                ) // Affiche le loader pendant le chargement
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const Text(
                        "BORDEREAU DE LIVRAISON",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sélection du client
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "Client"),
                        value: _selectedClientId,
                        items:
                            _clients
                                .map(
                                  (client) => DropdownMenuItem(
                                    value: client.id,
                                    child: Text(client.nom),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedClientId = val;
                            _selectedQuoteId = null;
                            _intituleController.clear();
                            _items.clear();
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Sélectionnez un client' : null,
                      ),
                      const SizedBox(height: 16),
                      // Sélection du devis confirmé
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Proforma confirmé",
                        ),
                        value: _selectedQuoteId,
                        items:
                            _filteredQuotes
                                .map(
                                  (quote) => DropdownMenuItem(
                                    value: quote.id,
                                    child: Text("Proforma #${quote.id}"),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedQuoteId = val;
                            final selectedQuote = _filteredQuotes.firstWhere(
                              (q) => q.id == val,
                            );

                            _intituleController.text =
                                "Livraison pour Proforma #${selectedQuote.id}";

                            _items =
                                selectedQuote.items
                                    .map(
                                      (e) => ArticleLivraison(
                                        ref: e.ref,
                                        description: e.description,
                                        quantity: e.quantity,
                                        status: BordereauModel.statusSubmitted,
                                      ),
                                    )
                                    .toList();

                            _warrantyDelay = "3 mois";
                            _deliveryDate = DateTime.now();
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Sélectionnez un devis' : null,
                      ),
                      const SizedBox(height: 16),
                      // Intitulé
                      TextFormField(
                        controller: _intituleController,
                        decoration: const InputDecoration(
                          labelText: "Intitulé du bordereau",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un intitulé';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Commercial ID
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Commercial ID",
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _selectedCommercialId,
                        onChanged: (val) {
                          setState(() {
                            _selectedCommercialId = val;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer l\'ID du commercial';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Délai de garantie
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Délai de garantie",
                        ),
                        initialValue: _warrantyDelay,
                        onChanged: (val) => _warrantyDelay = val,
                      ),
                      const SizedBox(height: 16),
                      // Date de livraison
                      ListTile(
                        title: Text(
                          "Date de livraison : ${DateFormat.yMd().add_Hm().format(_deliveryDate)}",
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _deliveryDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                _deliveryDate,
                              ),
                            );
                            if (time != null) {
                              setState(() {
                                _deliveryDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // État de livraison
                      DropdownButtonFormField<String>(
                        value: _deliveryStatus,
                        decoration: const InputDecoration(
                          labelText: "État de livraison",
                        ),
                        items:
                            ["Livré", "En cours", "Annulé"]
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => _deliveryStatus = val!),
                      ),
                      const SizedBox(height: 24),
                      // Aperçu des articles
                      if (_items.isNotEmpty) ...[
                        const Text(
                          "Articles à livrer :",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...(isEditing
                            ? _items.map(
                              (item) => ListTile(
                                title: Text(item.description),
                                subtitle: Text(
                                  "Réf: ${item.ref} - Qté: ${item.quantity} - Statut: ${item.status}",
                                ),
                              ),
                            )
                            : _items.map(
                              (item) => ListTile(
                                title: Text(item.description),
                                subtitle: Text(
                                  "Réf: ${item.ref} - Qté: ${item.quantity}",
                                ),
                              ),
                            )),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
      ),
    );
  }
}
