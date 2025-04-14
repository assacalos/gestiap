import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/data/models/bordereaux_model.dart';
import 'package:gestiap/features/commercial/views/providers/bordereaux_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';

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
  late String bordereauId; // Ajout de l'ID du bordereau
  late bool isEditing; // Ajout pour vérifier si on édite

  List<ArticleLivraison> _items = [];
  final TextEditingController _intituleController = TextEditingController();

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
      _items = List.from(
        bordereau.articles,
      ); // Créer une nouvelle liste mutable
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<BordereauxProvider>(
          context,
          listen: false,
        );
        provider.fetchClients();
        provider.fetchQuotes();
      }
    });
  }

  List<QuoteModel> get _filteredQuotes {
    final provider = Provider.of<BordereauxProvider>(context, listen: false);
    if (_selectedClientId == null) return [];
    return provider.quotes
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
        _selectedQuoteId != null) {
      final provider = Provider.of<BordereauxProvider>(context, listen: false);
      final client = provider.clients.firstWhere(
        (c) => c.id == _selectedClientId,
      );
      final quote = provider.quotes.firstWhere(
        (q) => q.id == _selectedQuoteId,
      ); // Récupérer la quote pour les détails

      return BordereauModel(
        id: bordereauId,
        clientId: client.id,
        clientName: client.nom,
        clientAdresse: client.adresse,
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
            ),
          ),
        ),
        status:
            isEditing
                ? widget.bordereauToEdit!.status
                : BordereauModel.statusDraft,
      );
    }
    return null;
  }

  // Fonction pour afficher une boîte de dialogue de confirmation avant la soumission
  Future<void> _showConfirmationDialog(
    BuildContext context,
    BordereauModel bordereau,
    BordereauxProvider bordereauxProvider,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // L'utilisateur doit interagir avec la boîte de dialogue
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
                Navigator.of(
                  dialogContext,
                ).pop(); // Fermer la boîte de dialogue
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text('Soumettre'),
              onPressed: () {
                bordereauxProvider.submitBordereau(
                  bordereau.id,
                ); // Appeler la fonction de soumission de votre provider
                Navigator.of(
                  dialogContext,
                ).pop(); // Fermer la boîte de dialogue
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bordereau soumis !')),
                );
                Navigator.pop(
                  context,
                ); // Retour à la page précédente après soumission
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
          if (isEditing &&
              widget.bordereauToEdit!.status.toLowerCase() ==
                  BordereauModel.statusDraft.toLowerCase())
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'save_draft',
            onPressed: () {
              final currentBordereau = _getCurrentBordereauFromForm();
              if (currentBordereau != null) {
                provider.saveDraftBordereau(currentBordereau);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bordereau enregistré comme brouillon.'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text("Enregistrer brouillon"),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'submit_fab',
            onPressed: () {
              final currentBordereau = _getCurrentBordereauFromForm();
              if (currentBordereau != null) {
                provider.submitBordereau(
                  currentBordereau.id,
                ); // Utilisez l'ID ici
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bordereau soumis !')),
                );
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.send),
            label: const Text("Soumettre"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "BORDEREAU DE LIVRAISON",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Sélection du client
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Client"),
                value: _selectedClientId, // Ajouter la valeur actuelle
                items:
                    provider.clients
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
                    (value) => value == null ? 'Sélectionnez un client' : null,
              ),

              const SizedBox(height: 16),

              // Sélection du devis confirmé
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Proforma confirmé",
                ),
                value: _selectedQuoteId, // Ajouter la valeur actuelle
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
                              ),
                            )
                            .toList();

                    _warrantyDelay = "3 mois";
                    _deliveryDate = DateTime.now();
                  });
                },
                validator:
                    (value) => value == null ? 'Sélectionnez un devis' : null,
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
                      initialTime: TimeOfDay.fromDateTime(_deliveryDate),
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
                onChanged: (val) => setState(() => _deliveryStatus = val!),
              ),

              const SizedBox(height: 24),

              // Aperçu des articles
              if (_items.isNotEmpty) ...[
                const Text(
                  "Articles à livrer :",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._items.map(
                  (item) => ListTile(
                    title: Text(item.description),
                    subtitle: Text("Réf: ${item.ref} - Qté: ${item.quantity}"),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
