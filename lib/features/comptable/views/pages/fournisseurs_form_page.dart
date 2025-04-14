import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/data/models/fournisseurs_model.dart';
import 'package:gestiap/features/comptable/views/providers/fournisseurs_provider.dart';
import 'package:provider/provider.dart';

class FournisseurFormPage extends StatefulWidget {
  final FournisseurModel? fournisseurToEdit;
  const FournisseurFormPage({super.key, this.fournisseurToEdit});

  @override
  _FournisseurFormPageState createState() => _FournisseurFormPageState();
}

class _FournisseurFormPageState extends State<FournisseurFormPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nomController = TextEditingController();
  TextEditingController _entrepriseController = TextEditingController();
  TextEditingController _adresseController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _informationsBancairesController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.fournisseurToEdit != null) {
      _nomController.text = widget.fournisseurToEdit!.nom;
      _entrepriseController.text = widget.fournisseurToEdit!.entreprise ?? '';
      _adresseController.text = widget.fournisseurToEdit!.adresse ?? '';
      _contactController.text = widget.fournisseurToEdit!.contact ?? '';
      _emailController.text = widget.fournisseurToEdit!.email ?? '';
      _informationsBancairesController.text =
          widget.fournisseurToEdit!.informationsBancaires ?? '';
    }
  }

  void _saveFournisseur() {
    if (_formKey.currentState!.validate()) {
      final fournisseur = FournisseurModel(
        id: widget.fournisseurToEdit?.id,
        nom: _nomController.text,
        entreprise:
            _entrepriseController.text.isNotEmpty
                ? _entrepriseController.text
                : null,
        adresse:
            _adresseController.text.isNotEmpty ? _adresseController.text : null,
        contact:
            _contactController.text.isNotEmpty ? _contactController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        informationsBancaires:
            _informationsBancairesController.text.isNotEmpty
                ? _informationsBancairesController.text
                : null,
      );
      final fournisseurProvider = Provider.of<FournisseurProvider>(
        context,
        listen: false,
      );
      if (widget.fournisseurToEdit == null) {
        fournisseurProvider.addFournisseur(fournisseur);
      } else {
        fournisseurProvider.updateFournisseur(fournisseur);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fournisseurToEdit == null
              ? 'Ajouter un Fournisseur'
              : 'Modifier le Fournisseur',
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
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom du Fournisseur',
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Champ obligatoire'
                            : null,
              ),
              TextFormField(
                controller: _entrepriseController,
                decoration: const InputDecoration(
                  labelText: 'Entreprise (Optionnel)',
                ),
              ),
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(
                  labelText: 'Adresse (Optionnel)',
                ),
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact (Optionnel)',
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optionnel)',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _informationsBancairesController,
                decoration: const InputDecoration(
                  labelText: 'Informations Bancaires (Optionnel)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveFournisseur,
                child: const Text('Enregistrer le Fournisseur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
