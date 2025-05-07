import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/data/models/fournisseurs_model.dart';
import 'package:gestiap/features/comptable/providers/fournisseurs_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; //Pour les CustomBottomNavigationBar

class FournisseurPage extends StatefulWidget {
  const FournisseurPage({Key? key}) : super(key: key);

  @override
  _FournisseurPageState createState() => _FournisseurPageState();
}

class _FournisseurPageState extends State<FournisseurPage> {
  int _currentPageIndex =
      0; // Indice de la page actuelle pour le BottomNavigationBar
  // Pas besoin d'un ChangeNotifierProvider ici, il doit être au-dessus dans l'arbre des widgets
  @override
  void initState() {
    super.initState();
    // La logique d'initialisation du provider doit être dans le main.dart ou un parent
    final fournisseurProvider = Provider.of<FournisseurProvider>(
      context,
      listen: false,
    );
    fournisseurProvider
        .loadFournisseurs(); // Charger les fournisseurs au démarrage de la page.
  }

  @override
  Widget build(BuildContext context) {
    // Consolider l'accès au FournisseurProvider
    final fournisseurProvider = Provider.of<FournisseurProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Fournisseurs'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Utilisation d'une Column pour organiser les éléments de la page
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Liste des Fournisseurs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Affichage de la liste des fournisseurs
            Expanded(
              // Utilisation de Expanded pour que la ListView occupe l'espace restant
              child: _buildFournisseurList(fournisseurProvider),
            ),
            const SizedBox(height: 20),
            // Bouton d'ajout de fournisseur
            ElevatedButton(
              onPressed: () {
                _showAddFournisseurDialog(context, fournisseurProvider);
              },
              child: const Text('Ajouter un fournisseur'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabChange: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        initialIndex: _currentPageIndex,
      ),
      // Assurez-vous que CustomBottomNavigationBar est correctement défini
    );
  }

  // Méthode pour construire la liste des fournisseurs
  Widget _buildFournisseurList(FournisseurProvider fournisseurProvider) {
    if (fournisseurProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Afficher un loader pendant le chargement
    } else if (fournisseurProvider.fournisseurs.isEmpty) {
      return const Center(
        child: Text('Aucun fournisseur trouvé.'),
      ); // Message si la liste est vide.
    } else {
      return ListView.builder(
        itemCount: fournisseurProvider.fournisseurs.length,
        itemBuilder: (context, index) {
          final FournisseurModel fournisseur =
              fournisseurProvider.fournisseurs[index];
          return _buildFournisseurListItem(fournisseur, fournisseurProvider);
        },
      );
    }
  }

  // Méthode pour construire chaque élément de la liste
  Widget _buildFournisseurListItem(
    FournisseurModel fournisseur,
    FournisseurProvider fournisseurProvider,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${fournisseur.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Nom: ${fournisseur.nom}'),
                Text('Contact: ${fournisseur.contact}'),
                Text('Email: ${fournisseur.email}'),
                Text('Adresse: ${fournisseur.adresse}'),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditFournisseurDialog(
                      context,
                      fournisseur,
                      fournisseurProvider,
                    ); // Passer le fournisseur à éditer
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteFournisseurDialog(
                      context,
                      fournisseur.id,
                      fournisseurProvider,
                    ); // Passer l'ID du fournisseur à supprimer
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour afficher la boîte de dialogue d'ajout de fournisseur
  void _showAddFournisseurDialog(
    BuildContext context,
    FournisseurProvider fournisseurProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    String nom = '';
    String entreprise = '';
    String contact = '';
    String email = '';
    String adresse = '';
    String informationsBancaires = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un fournisseur'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le nom du fournisseur';
                      }
                      return null;
                    },
                    onSaved: (value) => nom = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le numéro de téléphone';
                      }
                      // Vous pouvez ajouter une validation plus poussée pour le format du numéro de téléphone
                      return null;
                    },
                    onSaved: (value) => contact = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer l\'adresse email';
                      }
                      // Vous pouvez ajouter une validation plus poussée pour le format de l'email
                      return null;
                    },
                    onSaved: (value) => email = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Adresse'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer l\'adresse du fournisseur';
                      }
                      return null;
                    },
                    onSaved: (value) => adresse = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Informations Bancaires',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer les informations bancaires';
                      }
                      return null;
                    },
                    onSaved: (value) => informationsBancaires = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Entreprise'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le nom de l\'entreprise';
                      }
                      return null;
                    },
                    onSaved: (value) => entreprise = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newFournisseur = FournisseurModel(
                    id: DateTime.now().toString(), // Générer un ID unique
                    nom: nom,
                    contact: contact,
                    email: email,
                    adresse: adresse,
                    informationsBancaires: informationsBancaires,
                    entreprise: entreprise,
                  );
                  fournisseurProvider.addFournisseur(
                    newFournisseur,
                  ); // Utiliser la méthode du provider
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fournisseur ajouté avec succès!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour afficher la boîte de dialogue de modification de fournisseur
  void _showEditFournisseurDialog(
    BuildContext context,
    FournisseurModel fournisseurAModifier,
    FournisseurProvider fournisseurProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    String nom = fournisseurAModifier.nom;
    String contact = fournisseurAModifier.contact;
    String email = fournisseurAModifier.email;
    String adresse = fournisseurAModifier.adresse;
    String informationsBancaires = fournisseurAModifier.informationsBancaires;
    String entreprise = fournisseurAModifier.entreprise;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier un fournisseur'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: fournisseurAModifier.nom,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le nom du fournisseur';
                      }
                      return null;
                    },
                    onSaved: (value) => nom = value!,
                  ),
                  TextFormField(
                    initialValue: fournisseurAModifier.contact,
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le numéro de téléphone';
                      }
                      // Vous pouvez ajouter une validation plus poussée pour le format du numéro de téléphone
                      return null;
                    },
                    onSaved: (value) => contact = value!,
                  ),
                  TextFormField(
                    initialValue: fournisseurAModifier.email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer l\'adresse email';
                      }
                      // Vous pouvez ajouter une validation plus poussée pour le format de l'email
                      return null;
                    },
                    onSaved: (value) => email = value!,
                  ),
                  TextFormField(
                    initialValue: fournisseurAModifier.adresse,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer l\'adresse du fournisseur';
                      }
                      return null;
                    },
                    onSaved: (value) => adresse = value!,
                  ),
                  TextFormField(
                    initialValue: fournisseurAModifier.informationsBancaires,
                    decoration: const InputDecoration(
                      labelText: 'Informations Bancaires',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer les informations bancaires';
                      }
                      return null;
                    },
                    onSaved: (value) => informationsBancaires = value!,
                  ),
                  TextFormField(
                    initialValue: fournisseurAModifier.entreprise,
                    decoration: const InputDecoration(labelText: 'Entreprise'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le nom de l\'entreprise';
                      }
                      return null;
                    },
                    onSaved: (value) => entreprise = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Mettre à jour le fournisseur
                  final updatedFournisseur = FournisseurModel(
                    id:
                        fournisseurAModifier
                            .id, // Garder le même ID du fournisseur
                    nom: nom,
                    contact: contact,
                    email: email,
                    adresse: adresse,
                    informationsBancaires: informationsBancaires,
                    entreprise: entreprise,
                  );
                  fournisseurProvider.updateFournisseur(
                    updatedFournisseur,
                  ); // Utiliser la méthode update du provider

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fournisseur modifié avec succès!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour afficher la boîte de dialogue de confirmation de suppression
  void _showDeleteFournisseurDialog(
    BuildContext context,
    String fournisseurId,
    FournisseurProvider fournisseurProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer un fournisseur'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce fournisseur ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                fournisseurProvider.deleteFournisseur(
                  fournisseurId,
                ); // Utiliser la méthode delete du provider
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fournisseur supprimé avec succès!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
