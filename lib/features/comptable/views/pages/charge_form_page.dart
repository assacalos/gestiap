import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/data/models/charge_model.dart';
import 'package:gestiap/features/comptable/data/models/fournisseurs_model.dart';
import 'package:gestiap/features/comptable/views/providers/charges_provider.dart';
import 'package:gestiap/features/comptable/views/providers/fournisseurs_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Pour la sélection de fichier
import 'dart:io'; // Pour manipuler les fichiers
import 'package:firebase_storage/firebase_storage.dart'
    as firebase_storage; // Pour le stockage de fichiers

class DepenseFormPage extends StatefulWidget {
  final DepenseModel? depenseToEdit;
  const DepenseFormPage({super.key, this.depenseToEdit});

  @override
  _DepenseFormPageState createState() => _DepenseFormPageState();
}

class _DepenseFormPageState extends State<DepenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _montantController = TextEditingController();
  TextEditingController _categorieController = TextEditingController();
  String? _selectedFournisseurId;
  TextEditingController _referenceController = TextEditingController();
  String? _selectedMethodePaiement; // Pour la méthode de paiement
  File? _pieceJustificativeFile; // Pour stocker le fichier sélectionné
  String? _pieceJustificativeUrl; // Pour stocker l'URL après l'upload

  final List<String> _methodesPaiement = [
    'Espèces',
    'Carte Bancaire',
    'Virement Bancaire',
    'Chèque',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.depenseToEdit != null) {
      _descriptionController.text = widget.depenseToEdit!.description;
      _dateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.depenseToEdit!.date);
      _montantController.text = widget.depenseToEdit!.montant.toStringAsFixed(
        2,
      );
      _categorieController.text = widget.depenseToEdit!.categorie;
      _selectedFournisseurId = widget.depenseToEdit!.fournisseurId;
      _referenceController.text = widget.depenseToEdit!.reference ?? '';
      _selectedMethodePaiement = widget.depenseToEdit!.methodePaiement;
      _pieceJustificativeUrl = widget.depenseToEdit!.pieceJustificativeUrl;
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickPieceJustificative() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _pieceJustificativeFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadPieceJustificative() async {
    if (_pieceJustificativeFile == null) {
      return null;
    }
    try {
      final firebase_storage.Reference
      storageRef = firebase_storage.FirebaseStorage.instance.ref().child(
        'justificatifs_depenses/${DateTime.now().millisecondsSinceEpoch}_${_pieceJustificativeFile!.path.split('/').last}',
      );
      final firebase_storage.UploadTask uploadTask = storageRef.putFile(
        _pieceJustificativeFile!,
      );
      await uploadTask.whenComplete(() => null);
      final String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur lors de l\'upload du justificatif : $e');
      // Gérer l'erreur d'upload
      return null;
    }
  }

  void _saveDepense() async {
    if (_formKey.currentState!.validate()) {
      String? justificatifUrl = _pieceJustificativeUrl;
      if (_pieceJustificativeFile != null) {
        justificatifUrl = await _uploadPieceJustificative();
        if (justificatifUrl == null) {
          // Afficher un message d'erreur si l'upload échoue
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erreur lors de l\'upload de la pièce justificative.',
              ),
            ),
          );
          return;
        }
      }

      final depense = DepenseModel(
        id: widget.depenseToEdit?.id,
        description: _descriptionController.text,
        date: DateTime.parse(_dateController.text),
        montant: double.parse(_montantController.text),
        categorie: _categorieController.text,
        fournisseurId: _selectedFournisseurId,
        fournisseurNom:
            Provider.of<FournisseurProvider>(context, listen: false)
                .fournisseurs
                .firstWhere(
                  (f) => f.id == _selectedFournisseurId,
                  orElse: () => FournisseurModel(nom: '', id: ''),
                )
                .nom,
        reference:
            _referenceController.text.isNotEmpty
                ? _referenceController.text
                : null,
        methodePaiement: _selectedMethodePaiement,
        pieceJustificativeUrl: justificatifUrl,
      );
      final depenseProvider = Provider.of<DepenseProvider>(
        context,
        listen: false,
      );
      if (widget.depenseToEdit == null) {
        depenseProvider.addDepense(depense);
      } else {
        depenseProvider.updateDepense(depense);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.depenseToEdit == null
              ? 'Ajouter une Dépense'
              : 'Modifier la Dépense',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Champ obligatoire'
                            : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: () {
                  // Fonction synchrone anonyme
                  _selectDate(
                    context,
                  ); // Appel de votre fonction asynchrone ici
                },
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Champ obligatoire'
                            : null,
              ),
              TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Champ obligatoire'
                            : null,
              ),
              TextFormField(
                controller: _categorieController,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Champ obligatoire'
                            : null,
              ),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Référence (Optionnel)',
                ),
              ),
              const SizedBox(height: 16),
              Consumer<FournisseurProvider>(
                builder: (context, fournisseurProvider, child) {
                  if (fournisseurProvider.isLoading) {
                    return const CircularProgressIndicator();
                  }
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Fournisseur (Optionnel)',
                    ),
                    value: _selectedFournisseurId,
                    items:
                        fournisseurProvider.fournisseurs.map((fournisseur) {
                          return DropdownMenuItem<String>(
                            value: fournisseur.id,
                            child: Text(fournisseur.nom),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFournisseurId = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Méthode de Paiement (Optionnel)',
                ),
                value: _selectedMethodePaiement,
                items:
                    _methodesPaiement.map((method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMethodePaiement = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Pièce Justificative (Optionnel): '),
                  ElevatedButton(
                    onPressed: _pickPieceJustificative,
                    child: const Text('Choisir un Fichier'),
                  ),
                  if (_pieceJustificativeFile != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Fichier sélectionné: ${_pieceJustificativeFile!.path.split('/').last}',
                        ),
                      ),
                    ),
                  if (_pieceJustificativeUrl != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text('Fichier existant'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveDepense,
                child: const Text('Enregistrer la Dépense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
