import 'package:flutter/material.dart';
import 'package:gestiap/features/technicien/data/models/equipements_model.dart';
import 'package:gestiap/features/technicien/providers/equipements_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; //Pour les CustomBottomNavigationBar

class EquipementPage extends StatefulWidget {
  const EquipementPage({Key? key}) : super(key: key);

  @override
  _EquipementPageState createState() => _EquipementPageState();
}

class _EquipementPageState extends State<EquipementPage> {
  int _currentPageIndex =
      0; // Indice de la page actuelle pour le BottomNavigationBar
  // Pas besoin d'un ChangeNotifierProvider ici, il doit être au-dessus dans l'arbre des widgets
  @override
  void initState() {
    super.initState();
    // La logique d'initialisation du provider doit être dans le main.dart ou un parent
    final equipementProvider = Provider.of<EquipementProvider>(
      context,
      listen: false,
    );
    equipementProvider
        .getEquipements(); // Charger les équipements au démarrage de la page.
  }

  @override
  Widget build(BuildContext context) {
    // Consolider l'accès au EquipementProvider
    final equipementProvider = Provider.of<EquipementProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Équipements'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Utilisation d'une Column pour organiser les éléments de la page
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Liste des Équipements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Affichage de la liste des équipements
            Expanded(
              // Utilisation de Expanded pour que la ListView occupe l'espace restant
              child: _buildEquipementList(equipementProvider),
            ),
            const SizedBox(height: 20),
            // Bouton d'ajout d'équipement
            ElevatedButton(
              onPressed: () {
                _showAddEquipementDialog(context, equipementProvider);
              },
              child: const Text('Ajouter un équipement'),
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

  // Méthode pour construire la liste des équipements
  Widget _buildEquipementList(EquipementProvider equipementProvider) {
    if (equipementProvider.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Afficher un loader pendant le chargement
    } else if (equipementProvider.equipements.isEmpty) {
      return const Center(
        child: Text('Aucun équipement trouvé.'),
      ); // Message si la liste est vide.
    } else {
      return ListView.builder(
        itemCount: equipementProvider.equipements.length,
        itemBuilder: (context, index) {
          final EquipementModel equipement =
              equipementProvider.equipements[index];
          return _buildEquipementListItem(equipement, equipementProvider);
        },
      );
    }
  }

  // Méthode pour construire chaque élément de la liste
  Widget _buildEquipementListItem(
    EquipementModel equipement,
    EquipementProvider equipementProvider,
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
                  'ID: ${equipement.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Nom: ${equipement.nom}'),
                Text('Type: ${equipement.type}'),
                Text('État: ${equipement.etat}'),
                Text('Date d\'acquisition: ${equipement.dateAchat}'),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditEquipementDialog(
                      context,
                      equipementProvider.equipements, // Passer la liste
                      equipement,
                      equipementProvider,
                    ); // Passer l'équipement à éditer
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteEquipementDialog(
                      context,
                      equipement.id,
                      equipementProvider,
                    ); // Passer l'ID de l'équipement à supprimer
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour afficher la boîte de dialogue d'ajout d'équipement
  void _showAddEquipementDialog(
    BuildContext context,
    EquipementProvider equipementProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    String nom = '';
    String type = '';
    String marque = '';
    String modele = '';
    String numeroSerie = '';
    // Utilisation de String pour le numéro de série
    String etat = '';
    DateTime dateAchat = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un équipement'),
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
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                    onSaved: (value) => nom = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Type'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un type';
                      }
                      return null;
                    },
                    onSaved: (value) => type = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Marque'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une marque';
                      }
                      return null;
                    },
                    onSaved: (value) => type = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Modèle'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un modèle';
                      }
                      return null;
                    },
                    onSaved: (value) => type = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Numéro de série',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un numéro de série';
                      }
                      return null;
                    },
                    onSaved: (value) => type = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'État'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un état';
                      }
                      return null;
                    },
                    onSaved: (value) => etat = value!,
                  ),
                  // Utilisation de StatefulBuilder pour mettre à jour l'affichage de la date
                  StatefulBuilder(
                    builder: (context, setState) {
                      return ListTile(
                        title: Text(
                          'Date d\'acquisition: ${dateAchat.toLocal()}'.split(
                            ' ',
                          )[0],
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: dateAchat,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              dateAchat = selectedDate;
                            });
                          }
                        },
                      );
                    },
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
                  final newEquipement = EquipementModel(
                    id: DateTime.now().toString(), // Générer un ID unique
                    nom: nom,
                    type: type,
                    marque: marque,
                    modele: modele,
                    numeroSerie: numeroSerie,
                    etat: etat,
                    dateAchat: dateAchat,
                  );
                  equipementProvider.addEquipement(
                    newEquipement,
                  ); // Utiliser la méthode du provider
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Équipement ajouté avec succès!'),
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

  // Méthode pour afficher la boîte de dialogue de modification d'équipement
  void _showEditEquipementDialog(
    BuildContext context,
    List<EquipementModel> equipements,
    EquipementModel equipementAModifier,
    EquipementProvider equipementProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    String nom = equipementAModifier.nom;
    String type = equipementAModifier.type;
    String marque = equipementAModifier.marque;
    String modele = equipementAModifier.modele;
    String numeroSerie = equipementAModifier.numeroSerie;
    String etat = equipementAModifier.etat;
    DateTime dateAchat = equipementAModifier.dateAchat;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier un équipement'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: equipementAModifier.nom,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                    onSaved: (value) => nom = value!,
                  ),
                  TextFormField(
                    initialValue: equipementAModifier.type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un type';
                      }
                      return null;
                    },
                    onSaved: (value) => type = value!,
                  ),
                  TextFormField(
                    initialValue: equipementAModifier.etat,
                    decoration: const InputDecoration(labelText: 'État'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un état';
                      }
                      return null;
                    },
                    onSaved: (value) => etat = value!,
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return ListTile(
                        title: Text(
                          'Date d\'acquisition: ${dateAchat.toLocal()}'.split(
                            ' ',
                          )[0],
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: dateAchat,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              dateAchat = selectedDate;
                            });
                          }
                        },
                      );
                    },
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
                  // Mettre à jour l'équipement
                  final updatedEquipement = EquipementModel(
                    id: equipementAModifier.id, // Garder le même ID
                    nom: nom,
                    type: type,
                    marque: marque,
                    modele: modele,
                    numeroSerie: numeroSerie,
                    etat: etat,
                    dateAchat: dateAchat,
                  );
                  equipementProvider.updateEquipement(
                    updatedEquipement,
                  ); // Utiliser la méthode update du provider

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Équipement modifié avec succès!'),
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
  void _showDeleteEquipementDialog(
    BuildContext context,
    String equipementId,
    EquipementProvider equipementProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer un équipement'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cet équipement ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                equipementProvider.deleteEquipement(
                  equipementId,
                ); // Utiliser la méthode delete du provider
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Équipement supprimé avec succès!'),
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
