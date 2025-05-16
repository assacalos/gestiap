import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/bon_commande.dart';
import 'package:gestiap/features/commercial/providers/bonCommandes/bon_commande_provider.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:image_picker/image_picker.dart'; // Pour scanner/importer un document
import 'dart:io';

class BonDeCommandeFormPage extends StatefulWidget {
  final BonDeCommandeModel? bonDeCommandeToEdit;

  const BonDeCommandeFormPage({Key? key, this.bonDeCommandeToEdit})
    : super(key: key);

  @override
  _BonDeCommandeFormPageState createState() => _BonDeCommandeFormPageState();
}

class _BonDeCommandeFormPageState extends State<BonDeCommandeFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClientId;
  // String? _selectedBordereauId;
  String? _selectedProformaId;
  TextEditingController _acompteController = TextEditingController();
  String? _scannedDocumentUrl;
  File? _scannedDocumentFile;

  @override
  void initState() {
    super.initState();
    if (widget.bonDeCommandeToEdit != null) {
      _selectedClientId = widget.bonDeCommandeToEdit!.clientId;
      // _selectedBordereauId = widget.bonDeCommandeToEdit!.bordereauId;
      _selectedProformaId = widget.bonDeCommandeToEdit!.proformaId;
      _acompteController.text =
          widget.bonDeCommandeToEdit!.acompteRecu.toString();
      _scannedDocumentUrl = widget.bonDeCommandeToEdit!.documentScanneUrl;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).loadClients();
      Provider.of<QuoteProvider>(
        context,
        listen: false,
      ).loadQuotes(); // Assurez-vous d'avoir cette fonction
      // Peut-être fetchBordereaux liés au client sélectionné
    });
  }

  Future<void> _pickDocument() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    ); // Ou ImageSource.gallery
    if (pickedFile != null) {
      setState(() {
        _scannedDocumentFile = File(pickedFile.path);
        _scannedDocumentUrl =
            pickedFile
                .name; // Temporaire, l'URL réelle dépend du stockage cloud
        // TODO: Implémenter l'upload du fichier vers un stockage cloud et récupérer l'URL
      });
    }
  }

  BonDeCommandeModel? _getCurrentBonDeCommandeFromForm(double totalProforma) {
    if (_formKey.currentState!.validate() && _selectedClientId != null) {
      return BonDeCommandeModel(
        id: widget.bonDeCommandeToEdit?.id,
        clientId: _selectedClientId!,
        // bordereauId: _selectedBordereauId,
        proformaId: _selectedProformaId,
        documentScanneUrl: _scannedDocumentUrl,
        acompteRecu: double.tryParse(_acompteController.text) ?? 0.0,
        createdAt: widget.bonDeCommandeToEdit?.createdAt ?? DateTime.now(),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final clientsProvider = Provider.of<ClientProvider>(context);
    final proformaProvider = Provider.of<QuoteProvider>(context);
    double totalProforma =
        0.0; // Récupérer le total de la proforma sélectionnée

    if (_selectedProformaId != null) {
      final proforma = proformaProvider.quotes.firstWhere(
        (p) => p.id == _selectedProformaId,
        orElse:
            () => QuoteModel(
              // Fournir une instance par défaut
              id: '',
              clientId: '',
              clientName: '',
              description: '',
              amount: 0.0,
              createdAt: DateTime.now(),
              items: [],
              remise: 0.0,
              ref: 0,
              totalHT: 0.0,
              totalTTC: 0.0,
              commercialId: '', // Provide a default value here, important fix.
            ),
      );
      totalProforma =
          proforma?.totalHT ??
          0.0; // Assurez-vous d'avoir le champ totalHT dans votre ProformaModel
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bonDeCommandeToEdit == null
              ? 'Nouveau Bon de Commande'
              : 'Modifier Bon de Commande',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Client'),
                value: _selectedClientId,
                items:
                    clientsProvider.clients
                        .map(
                          (client) => DropdownMenuItem(
                            value: client.id,
                            child: Text(client.nom),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClientId = value;
                    // TODO: Filtrer les bordereaux et proformas associés à ce client si nécessaire
                  });
                },
                validator:
                    (value) => value == null ? 'Champ obligatoire' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Bordereau Associé (Optionnel)',
                ),
                //   value: _selectedBordereauId,
                items:
                    [], // TODO: Remplir avec les bordereaux du client sélectionné
                onChanged: (value) {
                  setState(() {
                    //    _selectedBordereauId = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Proforma Associée'),
                value: _selectedProformaId,
                items:
                    proformaProvider.quotes
                        .map(
                          (proforma) => DropdownMenuItem(
                            value: proforma.id,
                            child: Text(proforma.id),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProformaId = value;
                  });
                },
                validator:
                    (value) => value == null ? 'Champ obligatoire' : null,
              ),
              TextFormField(
                controller: _acompteController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Acompte Reçu'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Champ obligatoire';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un montant valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickDocument,
                icon: Icon(Icons.camera_alt),
                label: Text(
                  _scannedDocumentUrl == null
                      ? 'Scanner/Joindre Document'
                      : 'Document Joint: $_scannedDocumentUrl',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final bonDeCommande = _getCurrentBonDeCommandeFromForm(
                    totalProforma,
                  );
                  if (bonDeCommande != null) {
                    final bonDeCommandeProvider =
                        Provider.of<BonDeCommandeProvider>(
                          context,
                          listen: false,
                        );
                    if (widget.bonDeCommandeToEdit == null) {
                      bonDeCommandeProvider.addBonDeCommande(
                        context,
                        bonDeCommande,
                        totalProforma,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bon de commande soumis !'),
                        ),
                      );
                    } else {
                      bonDeCommandeProvider.updateBonDeCommande(
                        bonDeCommande,
                        totalProforma,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bon de commande mis à jour !'),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text('Soumettre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
