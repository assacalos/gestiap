import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/utils/Proforma_pdf_generator.dart';
import 'package:gestiap/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/services/auth_service.dart'; // Importez le service d'authentification

/* class DevisFormPage extends StatefulWidget {
  final QuoteModel? devisToEdit; // Paramètre pour l'édition
  const DevisFormPage({super.key, this.devisToEdit});

  @override
  _DevisFormPageState createState() => _DevisFormPageState();
}

class _DevisFormPageState extends State<DevisFormPage> {
  String? _selectedClientId;
  Map<String, dynamic>? _selectedClientData;
  final List<Map<String, dynamic>> _articles = [];
  final TextEditingController _remiseController = TextEditingController();
  late String devisId;
  late bool isEditing;
  String? _currentUserUid; // Stocker l'UID de l'utilisateur connecté
  bool _isSaving = false; // Variable pour suivre si une sauvegarde est en cours

  final TextEditingController _newRefController = TextEditingController();
  final TextEditingController _newDescController = TextEditingController();
  final TextEditingController _newPuhtController = TextEditingController();
  final TextEditingController _newQteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Charger les clients si non déjà chargés
    //Provider.of<ClientProvider>(context, listen: false).loadClients();
    isEditing = widget.devisToEdit != null;
    devisId =
        widget.devisToEdit?.id ?? "DV-${DateTime.now().millisecondsSinceEpoch}";
    if (isEditing && widget.devisToEdit != null) {
      _selectedClientId = widget.devisToEdit!.clientId;
      _remiseController.text = widget.devisToEdit!.remise.toString();
      _articles.addAll(
        widget.devisToEdit!.items.map(
          (item) => {
            'ref': item.ref.toString(), // Inclure la réf si elle existe
            'desc': item.description,
            'puht': item.unitPrice,
            'qte': item.quantity,
          },
        ),
      );
      // Récupérer les données du client si l'ID est disponible
      if (_selectedClientId != null) {
        _loadClientData(_selectedClientId!);
      }
    }
    // Récupérer l'utilisateur connecté
    _loadCurrentUser();
  }

  // Méthode pour récupérer l'utilisateur connecté
  void _loadCurrentUser() {
    final authProvider = Provider.of<AppAuthProvider>(
      context,
      listen: false,
    ); // Utilisez votre AuthService
    _currentUserUid = authProvider.user?.uid;
  }

  @override
  void dispose() {
    _newRefController.dispose();
    _newDescController.dispose();
    _newPuhtController.dispose();
    _newQteController.dispose();
    _remiseController.dispose();
    super.dispose();
  }

  Future<void> _loadClientData(String clientId) async {
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final client = clientProvider.clients.firstWhere(
      (c) => c.id == clientId,
      orElse:
          () => Client(
            id: '',
            nom: '',
            entreprise: '',
            situationGeographique: '',
            adresse: '',
            telephone: '',
            email: '',
          ), // Fallback
    );
    setState(() {
      _selectedClientData = client.toMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientsProvider = Provider.of<ClientProvider>(context);
    final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Modifier un proforma" : "Créer un proforma"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Le bouton soumettre fait aussi l'enregistrement
        onPressed: () async {
          // Empêcher les clics multiples pendant la sauvegarde
          if (_isSaving) return;
          setState(() {
            _isSaving =
                true; // Marquer comme en cours de sauvegarde pour éviter la double exécution
          });

          final currentQuote = _getCurrentQuoteFromForm();
          if (currentQuote != null) {
            try {
              if (isEditing) {
                // Mettre à jour le devis existant
                await quoteProvider.updateQuote(currentQuote);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Proforma mis à jour et soumis.'),
                  ),
                );
              } else {
                // Ajouter un nouveau devis
                await quoteProvider.addQuote(currentQuote);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proforma ajouté et soumis.')),
                );
              }
              //Soumettre le devis
              await quoteProvider.submitQuote(currentQuote.id);
              // Fermer la page après l'enregistrement et la soumission réussie
              if (mounted) {
                Navigator.pop(context);
              }
            } catch (error) {
              // Afficher un message d'erreur
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur : ${error.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            } finally {
              setState(() {
                _isSaving =
                    false; // Marquer comme non en cours de sauvegarde une fois l'opération terminée
              });
            }
          } else {
            setState(() {
              _isSaving =
                  false; // S'assurer de réinitialiser l'état même si la validation échoue
            });
          }
        },
        icon:
            _isSaving
                ? const CircularProgressIndicator(
                  color: Colors.white,
                ) // Afficher un indicateur de chargement
                : const Icon(Icons.send),
        label:
            _isSaving
                ? const Text('Enregistrement...')
                : Text(isEditing ? "Enregistrer et Soumettre" : "Soumettre"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildClientSelection(clientsProvider),
              const SizedBox(height: 20),
              _buildArticlesTable(),
              const SizedBox(height: 20),
              _buildFooter(),
              const SizedBox(height: 30),
              const Center(child: Text("Merci pour votre confiance")),
              const SizedBox(height: 20),
              if (widget.devisToEdit != null &&
                  widget.devisToEdit!.status ==
                      QuoteModel.statusPendingValidation)
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("Valider le devis"),
                    onPressed: () async {
                      try {
                        await quoteProvider.validateQuote(
                          widget.devisToEdit!.id,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Proforma validé !")),
                        );
                        Navigator.pop(context);
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur : ${error.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              if (widget.devisToEdit != null)
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Générer PDF"),
                    onPressed: () {
                      generateQuotePdf(widget.devisToEdit!);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/logoaleb.png', // Chemin vers votre logo
              height: 48, // Vous pouvez ajuster la taille
              width: 48,
            ),
            const SizedBox(height: 8),
            Text("Date : ${DateFormat('dd/MM/yyyy').format(DateTime.now())}"),
          ],
        ),
        Text("ID Devis: $devisId"),
      ],
    );
  }

  Widget _buildClientSelection(ClientProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Sélectionner un client",
                ),
                value: _selectedClientId,
                items:
                    provider.clients.isEmpty
                        ? const [
                          DropdownMenuItem(
                            value: null,
                            child: Text("Aucun client disponible"),
                          ),
                        ]
                        : provider.clients
                            .map(
                              (client) => DropdownMenuItem(
                                value: client.id,
                                child: Text(client.entreprise),
                              ),
                            )
                            .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedClientId = value;
                      _selectedClientData =
                          provider.clients
                              .firstWhere((c) => c.id == value)
                              .toMap();
                    });
                  }
                },
              ),
              if (_selectedClientData != null)
                _buildCompanyBlock(
                  _selectedClientData!["entreprise"],
                  _selectedClientData!["adresse"],
                  _selectedClientData!["telephone"],
                  _selectedClientData!["email"],
                  id: _selectedClientData!["id"],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyBlock(
    String title,
    String adresse,
    String contact,
    String email, {
    required String id,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("Adresse : $adresse"),
          Text("Contact : $contact"),
          Text("Email : $email"),
          Text("ID : $id"),
        ],
      ),
    );
  }

  QuoteModel? _getCurrentQuoteFromForm() {
    if (_selectedClientId == null || _articles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sélectionner un client et ajouter des articles."),
        ),
      );
      return null;
    }

    final total = _calculateTotal();
    return QuoteModel(
      id: devisId,
      clientId: _selectedClientId!,
      clientName: _selectedClientData?["entreprise"] ?? "",
      description:
          "", // Vous pouvez ajouter un champ de description si nécessaire
      amount: total,
      createdAt:
          isEditing && widget.devisToEdit != null
              ? widget.devisToEdit!.createdAt
              : DateTime.now(), // Garder la date existante en cas de modification
      status:
          isEditing
              ? widget.devisToEdit!.status
              : QuoteModel
                  .statusPendingValidation, // Statut directement à 'En attente'
      ref: widget.devisToEdit?.ref ?? 0,
      remise: double.tryParse(_remiseController.text) ?? 0,
      items:
          _articles.map((item) {
            return QuoteItem(
              description: item['desc'] ?? "",
              quantity: item['qte'] ?? 0,
              unitPrice: item['puht'] ?? 0.0,
              ref: int.tryParse(item['ref']?.toString() ?? '') ?? 0,
            );
          }).toList(),
      commercialId:
          _currentUserUid ??
          "", // Utiliser l'UID de l'utilisateur connecté ou une chaîne vide par défaut
      totalHT:
          total / (1 - (double.tryParse(_remiseController.text) ?? 0) / 100),
      totalTTC: total, // Le total TTC est déjà calculé avec la remise
    );
  }

  Widget _buildArticlesTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(child: Text("Référence")),
            Expanded(child: Text("Description")),
            Expanded(child: Text("PUHT")),
            Expanded(child: Text("Quantité")),
            SizedBox(width: 40), // Espace pour le bouton de suppression
          ],
        ),
        const Divider(),
        ..._articles.asMap().entries.map((entry) {
          final index = entry.key;
          final article = entry.value;
          final refController = TextEditingController(
            text: article['ref']?.toString() ?? '',
          );
          final descController = TextEditingController(
            text: article['desc'] ?? '',
          );
          final puhtController = TextEditingController(
            text: article['puht']?.toString() ?? '',
          );
          final qteController = TextEditingController(
            text: article['qte']?.toString() ?? '',
          );

          refController.addListener(
            () => _updateArticle(index, 'ref', refController.text),
          );
          descController.addListener(
            () => _updateArticle(index, 'desc', descController.text),
          );
          puhtController.addListener(
            () => _updateArticle(
              index,
              'puht',
              double.tryParse(puhtController.text) ?? 0,
            ),
          );
          qteController.addListener(
            () => _updateArticle(
              index,
              'qte',
              int.tryParse(qteController.text) ?? 0,
            ),
          );

          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: refController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: descController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: puhtController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: qteController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                onPressed: () => _removeArticle(index),
              ),
            ],
          );
        }).toList(),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newRefController,
                decoration: const InputDecoration(labelText: "Réf"),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _newDescController,
                decoration: const InputDecoration(labelText: "Desc"),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _newPuhtController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "PUHT"),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _newQteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Qté"),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () {
                setState(() {
                  _articles.add({
                    'ref': _newRefController.text,
                    'desc': _newDescController.text,
                    'puht': double.tryParse(_newPuhtController.text) ?? 0,
                    'qte': int.tryParse(_newQteController.text) ?? 0,
                  });
                  _newRefController.clear();
                  _newDescController.clear();
                  _newPuhtController.clear();
                  _newQteController.clear();
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            children: [Text("Cachet numérique"), FlutterLogo(size: 48)],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _remiseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Remise (%)"),
                onChanged:
                    (value) =>
                        setState(() {}), // Rebuild pour recalculer le total
              ),
              const SizedBox(height: 8),
              Text("Total : ${_calculateTotal().toStringAsFixed(2)} FCFA"),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateTotal() {
    double total = _articles.fold(
      0.0,
      (sum, item) => sum + (item['puht'] * item['qte']),
    );
    final remise = double.tryParse(_remiseController.text) ?? 0;
    return total * (1 - (remise / 100));
  }

  void _updateArticle(int index, String key, dynamic value) {
    setState(() {
      _articles[index][key] = value;
    });
  }

  void _removeArticle(int index) {
    setState(() {
      _articles.removeAt(index);
    });
  }
} */

class DevisFormPage extends StatefulWidget {
  final QuoteModel? devisToEdit; // Paramètre pour l'édition
  const DevisFormPage({super.key, this.devisToEdit});

  @override
  _DevisFormPageState createState() => _DevisFormPageState();
}

class _DevisFormPageState extends State<DevisFormPage> {
  String? _selectedClientId;
  Map<String, dynamic>? _selectedClientData;
  final List<Map<String, dynamic>> _articles = [];
  final TextEditingController _remiseController = TextEditingController();
  late String devisId;
  late bool isEditing;
  String? _currentUserUid; // Stocker l'UID de l'utilisateur connecté
  bool _isSaving = false; // Variable pour suivre si une sauvegarde est en cours

  final TextEditingController _newRefController = TextEditingController();
  final TextEditingController _newDescController = TextEditingController();
  final TextEditingController _newPuhtController = TextEditingController();
  final TextEditingController _newQteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isEditing = widget.devisToEdit != null;
    devisId =
        widget.devisToEdit?.id ?? "DV-${DateTime.now().millisecondsSinceEpoch}";
    _loadInitialData();
    _loadCurrentUser();
  }

  void _loadInitialData() {
    if (isEditing && widget.devisToEdit != null) {
      _selectedClientId = widget.devisToEdit!.clientId;
      _remiseController.text = widget.devisToEdit!.remise.toString();
      _articles.addAll(
        widget.devisToEdit!.items.map(
          (item) => {
            'ref': item.ref.toString(), // Inclure la réf si elle existe
            'desc': item.description,
            'puht': item.unitPrice,
            'qte': item.quantity,
          },
        ),
      );
      if (_selectedClientId != null) {
        _loadClientData(_selectedClientId!);
      }
    }
  }

  // Méthode pour récupérer l'utilisateur connecté
  void _loadCurrentUser() {
    final authProvider = Provider.of<AppAuthProvider>(
      context,
      listen: false,
    ); // Utilisez votre AuthService
    _currentUserUid = authProvider.user?.uid;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _newRefController.dispose();
    _newDescController.dispose();
    _newPuhtController.dispose();
    _newQteController.dispose();
    _remiseController.dispose();
  }

  Future<void> _loadClientData(String clientId) async {
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    try {
      final client = clientProvider.clients.firstWhere((c) => c.id == clientId);
      setState(() {
        _selectedClientData = client.toMap();
      });
    } catch (e) {
      // Gérer le cas où le client n'est pas trouvé.  C'est important.
      print("Client not found: $e"); // Log the error
      setState(() {
        _selectedClientData = null; // or an empty map: {}
      });
      // Show a message to the user?
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Client not found."),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsProvider = Provider.of<ClientProvider>(context);
    final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Modifier un proforma" : "Créer un proforma"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildClientSelection(clientsProvider),
              const SizedBox(height: 20),
              _buildArticlesTable(),
              const SizedBox(height: 20),
              _buildFooter(),
              const SizedBox(height: 30),
              const Center(child: Text("Merci pour votre confiance")),
              const SizedBox(height: 20),
              if (widget.devisToEdit != null &&
                  widget.devisToEdit!.status ==
                      QuoteModel.statusPendingValidation)
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("Valider le devis"),
                    onPressed: () async {
                      try {
                        await quoteProvider.validateQuote(
                          widget.devisToEdit!.id,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Proforma validé !")),
                        );
                        Navigator.pop(context);
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur : ${error.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              if (widget.devisToEdit != null)
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Générer PDF"),
                    onPressed: () {
                      generateQuotePdf(widget.devisToEdit!);
                    },
                  ),
                ),
              const SizedBox(height: 30),

              // BOUTON DE SOUMISSION ALIGNÉ EN BAS, TOUTE LA LARGEUR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon:
                      _isSaving
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.send),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      _isSaving
                          ? 'Enregistrement...'
                          : (isEditing
                              ? "Enregistrer et Soumettre"
                              : "Soumettre"),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  onPressed:
                      _isSaving
                          ? null
                          : () async {
                            setState(() {
                              _isSaving = true;
                            });

                            final currentQuote = _getCurrentQuoteFromForm();
                            if (currentQuote != null) {
                              try {
                                if (isEditing) {
                                  await quoteProvider.updateQuote(currentQuote);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Proforma mis à jour et soumis.',
                                      ),
                                    ),
                                  );
                                } else {
                                  await quoteProvider.addQuote(currentQuote);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Proforma ajouté et soumis.',
                                      ),
                                    ),
                                  );
                                }

                                await quoteProvider.submitQuote(
                                  currentQuote.id,
                                );
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              } catch (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Erreur : ${error.toString()}',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() {
                                  _isSaving = false;
                                });
                              }
                            } else {
                              setState(() {
                                _isSaving = false;
                              });
                            }
                          },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*  VoidCallback _handleSaveAndSubmit(QuoteProvider quoteProvider) {
    return () async {
      if (_isSaving) return;
      setState(() {
        _isSaving = true;
      });

      final currentQuote = _getCurrentQuoteFromForm();
      if (currentQuote != null) {
        try {
          if (isEditing) {
            await quoteProvider.updateQuote(currentQuote);
            _showSnackBar('Proforma mis à jour et soumis.');
          } else {
            await quoteProvider.addQuote(currentQuote);
            _showSnackBar('Proforma ajouté et soumis.');
          }
          await quoteProvider.submitQuote(currentQuote.id);
          if (mounted) {
            Navigator.pop(context);
          }
        } catch (error) {
          _showErrorSnackBar(error);
        } finally {
          setState(() {
            _isSaving = false;
          });
        }
      } else {
        setState(() {
          _isSaving = false;
        });
      }
    };
  } */

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorSnackBar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur : ${error.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Icône dynamique
  Widget _buildSaveAndSubmitIcon() {
    return _isSaving
        ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
        : const Icon(Icons.send);
  }

  // Label dynamique
  Widget _buildSaveAndSubmitLabel() {
    return Text(
      _isSaving
          ? 'Enregistrement...'
          : (isEditing ? 'Enregistrer et Soumettre' : 'Soumettre'),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildValidationButton(QuoteProvider quoteProvider) {
    if (widget.devisToEdit != null &&
        widget.devisToEdit!.status == QuoteModel.statusPendingValidation) {
      return Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text("Valider le devis"),
          onPressed: () async {
            try {
              await quoteProvider.validateQuote(widget.devisToEdit!.id);
              _showSnackBar("Proforma validé !");
              if (mounted) {
                Navigator.pop(context);
              }
            } catch (error) {
              _showErrorSnackBar(error);
            }
          },
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildGeneratePdfButton() {
    if (widget.devisToEdit != null) {
      return Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Générer PDF"),
          onPressed: () {
            generateQuotePdf(widget.devisToEdit!);
          },
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/logoaleb.png', // Chemin vers votre logo
              height: 48,
              width: 48,
            ),
            const SizedBox(height: 8),
            Text("Date : ${DateFormat('dd/MM/yyyy').format(DateTime.now())}"),
          ],
        ),
        Text("ID Devis: $devisId"),
      ],
    );
  }

  Widget _buildClientSelection(ClientProvider clientProvider) {
    final validClients =
        clientProvider.clients
            .where((client) => client.status == Client.statusValidated)
            .toList();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Sélectionner un client",
                ),
                value: _selectedClientId,
                onChanged: (value) => _onClientChanged(value, clientProvider),
                items: _buildClientDropdownItems(validClients),
              ),
              if (_selectedClientData != null)
                _buildCompanyBlock(
                  _selectedClientData!["entreprise"],
                  _selectedClientData!["adresse"],
                  _selectedClientData!["telephone"],
                  _selectedClientData!["email"],
                  id: _selectedClientData!["id"],
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _onClientChanged(String? value, ClientProvider clientProvider) {
    if (value != null) {
      setState(() {
        _selectedClientId = value;
        _loadClientData(value); // Always load data.
      });
    }
  }

  List<DropdownMenuItem<String>> _buildClientDropdownItems(
    List<Client> clients,
  ) {
    if (clients.isEmpty) {
      return const [
        DropdownMenuItem(value: null, child: Text("Aucun client disponible")),
      ];
    }
    return clients
        .map(
          (client) => DropdownMenuItem(
            value: client.id,
            child: Text(client.entreprise),
          ),
        )
        .toList();
  }

  Widget _buildCompanyBlock(
    String title,
    String adresse,
    String contact,
    String email, {
    required String id,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("Adresse : $adresse"),
          Text("Contact : $contact"),
          Text("Email : $email"),
          Text("ID : $id"),
        ],
      ),
    );
  }

  QuoteModel? _getCurrentQuoteFromForm() {
    if (_selectedClientId == null || _articles.isEmpty) {
      _showSnackBar("Sélectionner un client et ajouter des articles.");
      return null;
    }

    final total = _calculateTotal();
    return QuoteModel(
      id: devisId,
      clientId: _selectedClientId!,
      clientName: _selectedClientData?["entreprise"] ?? "",
      description: "",
      amount: total,
      createdAt:
          isEditing && widget.devisToEdit != null
              ? widget.devisToEdit!.createdAt
              : DateTime.now(),
      status:
          isEditing
              ? widget.devisToEdit!.status
              : QuoteModel.statusPendingValidation,
      ref: widget.devisToEdit?.ref ?? 0,
      remise: double.tryParse(_remiseController.text) ?? 0,
      items: _articles.map((item) => _mapToQuoteItem(item)).toList(),
      commercialId: _currentUserUid ?? "",
      totalHT:
          total / (1 - (double.tryParse(_remiseController.text) ?? 0) / 100),
      totalTTC: total,
    );
  }

  QuoteItem _mapToQuoteItem(Map<String, dynamic> item) {
    return QuoteItem(
      description: item['desc'] ?? "",
      quantity: item['qte'] ?? 0,
      unitPrice: item['puht'] ?? 0.0,
      ref: int.tryParse(item['ref']?.toString() ?? '') ?? 0,
    );
  }

  Widget _buildArticlesTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(child: Text("Référence")),
            Expanded(child: Text("Description")),
            Expanded(child: Text("PUHT")),
            Expanded(child: Text("Quantité")),
            SizedBox(width: 40),
          ],
        ),
        const Divider(),
        ..._buildArticleRows(),
        _buildAddArticleRow(),
      ],
    );
  }

  List<Widget> _buildArticleRows() {
    return _articles.asMap().entries.map((entry) {
      final index = entry.key;
      final article = entry.value;
      return _buildArticleRow(index, article);
    }).toList();
  }

  Row _buildArticleRow(int index, Map<String, dynamic> article) {
    final refController = TextEditingController(
      text: article['ref']?.toString() ?? '',
    );
    final descController = TextEditingController(text: article['desc'] ?? '');
    final puhtController = TextEditingController(
      text: article['puht']?.toString() ?? '',
    );
    final qteController = TextEditingController(
      text: article['qte']?.toString() ?? '',
    );

    refController.addListener(
      () => _updateArticle(index, 'ref', refController.text),
    );
    descController.addListener(
      () => _updateArticle(index, 'desc', descController.text),
    );
    puhtController.addListener(
      () => _updateArticle(
        index,
        'puht',
        double.tryParse(puhtController.text) ?? 0,
      ),
    );
    qteController.addListener(
      () => _updateArticle(index, 'qte', int.tryParse(qteController.text) ?? 0),
    );

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: refController,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        Expanded(
          child: TextField(
            controller: descController,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        Expanded(
          child: TextField(
            controller: puhtController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        Expanded(
          child: TextField(
            controller: qteController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_forever, color: Colors.red),
          onPressed: () => _removeArticle(index),
        ),
      ],
    );
  }

  Row _buildAddArticleRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _newRefController,
            decoration: const InputDecoration(labelText: "Réf"),
          ),
        ),
        Expanded(
          child: TextField(
            controller: _newDescController,
            decoration: const InputDecoration(labelText: "Desc"),
          ),
        ),
        Expanded(
          child: TextField(
            controller: _newPuhtController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "PUHT"),
          ),
        ),
        Expanded(
          child: TextField(
            controller: _newQteController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Qté"),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green),
          onPressed: _addArticle,
        ),
      ],
    );
  }

  void _addArticle() {
    setState(() {
      _articles.add({
        'ref': _newRefController.text,
        'desc': _newDescController.text,
        'puht': double.tryParse(_newPuhtController.text) ?? 0,
        'qte': int.tryParse(_newQteController.text) ?? 0,
      });
      _clearNewArticleFields();
    });
  }

  void _clearNewArticleFields() {
    _newRefController.clear();
    _newDescController.clear();
    _newPuhtController.clear();
    _newQteController.clear();
  }

  Widget _buildFooter() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            children: [Text("Cachet numérique"), FlutterLogo(size: 48)],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _remiseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Remise (%)"),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Text("Total : ${_calculateTotal().toStringAsFixed(2)} FCFA"),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateTotal() {
    double total = _articles.fold(
      0.0,
      (sum, item) => sum + (item['puht'] * item['qte']),
    );
    final remise = double.tryParse(_remiseController.text) ?? 0;
    return total * (1 - (remise / 100));
  }

  void _updateArticle(int index, String key, dynamic value) {
    setState(() {
      _articles[index][key] = value;
    });
  }

  void _removeArticle(int index) {
    setState(() {
      _articles.removeAt(index);
    });
  }
}
