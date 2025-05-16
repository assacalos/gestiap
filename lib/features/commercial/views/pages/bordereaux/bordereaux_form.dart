import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestiap/providers/auth_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/utils/bordereaux_pdf_generator.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:intl/intl.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/providers/bordereaux/bordereaux_provider.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importez ceci

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
  final TextEditingController _warrantyDelayController =
      TextEditingController();
  DateTime _deliveryDate = DateTime.now();
  late String bordereauId;
  late bool isEditing;
  List<ArticleLivraison> _items = [];
  final TextEditingController _intituleController = TextEditingController();
  String? _selectedCommercialId;
  List<Client> _clients = [];
  List<QuoteModel> _quotes = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    isEditing = widget.bordereauToEdit != null;
    bordereauId =
        widget.bordereauToEdit?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    if (isEditing) {
      _warrantyDelayController.text = widget.bordereauToEdit!.delaiGarantie;
      _intituleController.text = widget.bordereauToEdit!.intitule;
      _selectedClientId = widget.bordereauToEdit!.clientId;
      _selectedQuoteId = widget.bordereauToEdit!.devisId;
      _deliveryStatus = widget.bordereauToEdit!.etatLivraison;
      _deliveryDate = widget.bordereauToEdit!.dateLivraison;
      _items = List.from(widget.bordereauToEdit!.articles);
      _selectedCommercialId = widget.bordereauToEdit!.commercialId;
    }

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final commercialId = authProvider.user?.uid;
    _selectedCommercialId = commercialId;
    _loadData();
  }

  @override
  void dispose() {
    _warrantyDelayController.dispose();
    _intituleController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (mounted) {
      final bordereauxProvider = Provider.of<BordereauxProvider>(
        context,
        listen: false,
      );
      try {
        await bordereauxProvider.clientProvider.loadClients();
        await bordereauxProvider.quoteProvider.loadQuotes();
        _clients = bordereauxProvider.clientProvider.clients;
        _quotes = bordereauxProvider.quoteProvider.quotes;
      } catch (e) {
        print("Erreur lors du chargement des données : $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Échec du chargement des données : ${e.toString()}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
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
              q.status.trim().toLowerCase() == 'validé',
        )
        .toList();
  }

  List<Client> get _validatedClients {
    return _clients
        .where((client) => client.status.trim().toLowerCase() == 'validé')
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
        clientEntreprise: client.entreprise,
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
        delaiGarantie: _warrantyDelayController.text,
        articles: _items,
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
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog first.
                setState(() {
                  _isSaving = true;
                });
                try {
                  await bordereauxProvider.addBordereau(bordereau, context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bordereau soumis !')),
                    );
                    Navigator.pop(context); // Pop the form page.
                  }
                } catch (error) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de la soumission: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isSaving = false;
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSaveAndSubmitIcon() {
    return _isSaving
        ? const CircularProgressIndicator(color: Colors.white)
        : const Icon(Icons.send);
  }

  Future<void> _displayPdf(List<int> pdfBytes, String fileName) async {
    try {
      final outputDir = await getTemporaryDirectory();
      final filePath = '${outputDir.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(pdfBytes);

      final result = await OpenFile.open(file.path);

      if (result.type != ResultType.done) {
        debugPrint('Erreur lors de l\'ouverture du PDF : ${result.message}');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'affichage du PDF : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BordereauxProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Modifier un Bordereau" : "Créer un Bordereau"),
        actions: [
          if (isEditing && widget.bordereauToEdit!.status == "Rejeté")
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Supprimer le bordereau'),
                        content: const Text(
                          'Êtes-vous sûr de vouloir supprimer ce bordereau ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.deleteBordereau(
                                widget.bordereauToEdit!.id,
                                context,
                              );
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                );
              },
            ),
          if (isEditing && widget.bordereauToEdit!.status == "Validé")
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () async {
                final pdfBytes = await BordereauPdfGenerator.generatePdf(
                  widget.bordereauToEdit!,
                );
                _displayPdf(
                  pdfBytes,
                  "Bordereau_${widget.bordereauToEdit!.id}.pdf",
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
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
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "Client"),
                        value: _selectedClientId,
                        items:
                            _validatedClients
                                .map(
                                  (client) => DropdownMenuItem(
                                    value: client.id,
                                    child: Text(client.entreprise),
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
                                selectedQuote.items.map((item) {
                                  final existingItem =
                                      isEditing
                                          ? _items.firstWhere(
                                            (existing) =>
                                                existing.ref == item.ref,
                                            orElse:
                                                () => ArticleLivraison(
                                                  ref: item.ref,
                                                  description: item.description,
                                                  quantity: item.quantity,
                                                  status:
                                                      BordereauModel
                                                          .statusPendingValidation,
                                                ),
                                          )
                                          : ArticleLivraison(
                                            ref: item.ref,
                                            description: item.description,
                                            quantity: item.quantity,
                                            status:
                                                BordereauModel
                                                    .statusPendingValidation,
                                          );
                                  return existingItem;
                                }).toList();
                            _deliveryDate = DateTime.now();
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Sélectionnez un devis' : null,
                      ),
                      const SizedBox(height: 16),
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
                      TextFormField(
                        controller: _warrantyDelayController,
                        decoration: const InputDecoration(
                          labelText: "Délai de garantie",
                        ),
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 24),
                      if (_items.isNotEmpty) ...[
                        const Text(
                          "Articles à livrer :",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children:
                              _items.map((item) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return ListTile(
                                      title: Text(item.description),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Réf: ${item.ref} - Quantité: ${item.quantity}",
                                          ),
                                          DropdownButtonFormField<String>(
                                            value: item.status,
                                            items: const [
                                              DropdownMenuItem(
                                                value:
                                                    BordereauModel
                                                        .statusPendingValidation,
                                                child: Text(
                                                  "En attente de validation",
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value:
                                                    BordereauModel
                                                        .statusValidated,
                                                child: Text("Livré"),
                                              ),
                                              DropdownMenuItem(
                                                value:
                                                    BordereauModel
                                                        .statusRejected,
                                                child: Text("Annulé"),
                                              ),
                                            ],
                                            onChanged: (val) {
                                              setState(() {
                                                item.status = val!;
                                                if (val !=
                                                    BordereauModel
                                                        .statusPendingValidation) {
                                                  item.tempsEstimation = null;
                                                }
                                              });
                                            },
                                            validator:
                                                (value) =>
                                                    value == null ||
                                                            value.isEmpty
                                                        ? 'Sélectionnez un statut'
                                                        : null,
                                          ),
                                          if (item.status ==
                                              BordereauModel
                                                  .statusPendingValidation)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: TextFormField(
                                                initialValue:
                                                    item.tempsEstimation,
                                                decoration: const InputDecoration(
                                                  labelText:
                                                      'Temps d\'estimation (ex: 3 jours)',
                                                  border: OutlineInputBorder(),
                                                ),
                                                onChanged: (val) {
                                                  item.tempsEstimation = val;
                                                },
                                                validator: (val) {
                                                  if (item.status ==
                                                          BordereauModel
                                                              .statusPendingValidation &&
                                                      (val == null ||
                                                          val.isEmpty)) {
                                                    return 'Entrez un temps d\'estimation';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ],
                  ),
                ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            final currentBordereau = _getCurrentBordereauFromForm();
            if (currentBordereau != null) {
              final provider = Provider.of<BordereauxProvider>(
                context,
                listen: false,
              );
              _showConfirmationDialog(context, currentBordereau, provider);
            } else {
              // Affiche un message d'erreur si le formulaire est incomplet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Veuillez remplir correctement tous les champs.',
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSaveAndSubmitIcon(),
              const SizedBox(width: 8),
              const Text('Soumission'),
            ],
          ),
        ),
      ),
    );
  }
}
