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
    // Charger les clients si non déjà chargés
    Provider.of<ClientProvider>(context, listen: false).loadClients();
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
              Navigator.pop(context);
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
            const FlutterLogo(size: 48),
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
}
