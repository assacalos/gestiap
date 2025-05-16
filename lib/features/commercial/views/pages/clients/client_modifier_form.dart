import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/client_model.dart';
import 'package:gestiap/features/commercial/providers/clients/clients_provider.dart';
import 'package:gestiap/providers/auth_provider.dart'; // Importez votre AuthProvider

class ClientFormPage extends StatefulWidget {
  final Client? clientToEdit;
  const ClientFormPage({Key? key, this.clientToEdit}) : super(key: key);

  @override
  _ClientFormPageState createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
  // Controllers pour les champs du formulaire
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _entrepriseController = TextEditingController();
  final TextEditingController _situationGeographiqueController =
      TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _currentUserUid; // L'UID de l'utilisateur connecté
  bool _isSaving = false;
  late bool isEditing;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isEditing = widget.clientToEdit != null;
    _initializeForm();
    _loadCurrentUser();
  }

  void _initializeForm() {
    if (widget.clientToEdit != null) {
      _nomController.text = widget.clientToEdit!.nom;
      _entrepriseController.text = widget.clientToEdit!.entreprise;
      _situationGeographiqueController.text =
          widget.clientToEdit!.situationGeographique;
      _adresseController.text = widget.clientToEdit!.adresse;
      _telephoneController.text = widget.clientToEdit!.telephone;
      _emailController.text = widget.clientToEdit!.email;
    }
  }

  // Méthode pour charger l'utilisateur actuel
  void _loadCurrentUser() {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    _currentUserUid = authProvider.user?.uid;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _entrepriseController.dispose();
    _situationGeographiqueController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.clientToEdit == null
              ? "Ajouter un client"
              : "Modifier un client",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildTextField(
                  controller: _entrepriseController,
                  label: "Entreprise",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer le nom de l'entreprise";
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _nomController,
                  label: "Nom",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer le nom du client";
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _telephoneController,
                  label: "Téléphone",
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer le numéro de téléphone";
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return "Numéro de téléphone invalide (10 chiffres)";
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer l'adresse email";
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return "Adresse email invalide";
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _adresseController,
                  label: "Adresse",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer l'adresse";
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _situationGeographiqueController,
                  label: "Situation Géographique",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer la situation géographique";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildSubmitButton(clientProvider), // Renamed button
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  // Méthode pour construire le bouton de soumission
  Widget _buildSubmitButton(ClientProvider clientProvider) {
    return ElevatedButton(
      onPressed: () => _submitClient(clientProvider), // Méthode renommée
      child:
          _isSaving
              ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
              : Text(
                widget.clientToEdit == null ? "Soumettre" : "Modifier",
              ), // Texte modifié
    );
  }

  // Méthode pour gérer la soumission du client
  Future<void> _submitClient(ClientProvider clientProvider) async {
    // Méthode renommée
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final client = Client(
        id: widget.clientToEdit?.id ?? '',
        nom: _nomController.text,
        entreprise: _entrepriseController.text,
        situationGeographique: _situationGeographiqueController.text,
        adresse: _adresseController.text,
        telephone: _telephoneController.text,
        email: _emailController.text,
        commercialId: _currentUserUid ?? "",
        status:
            isEditing
                ? widget.clientToEdit!.status
                : Client.statusPendingValidation,

        // Utilisez l'UID de l'utilisateur connecté
      );

      try {
        if (widget.clientToEdit == null) {
          await clientProvider.addClient(client);
          _showSnackBar("Client ajouté avec succès");
        } else {
          await clientProvider.updateClient(client);
          _showSnackBar("Client modifié avec succès");
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (error) {
        _showErrorSnackBar(
          "Erreur lors de la soumission du client: $error",
        ); // Message d'erreur modifié
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    } else {
      _showSnackBar("Veuillez remplir correctement le formulaire");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
