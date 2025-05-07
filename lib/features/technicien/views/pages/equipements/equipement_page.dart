import 'package:flutter/material.dart';
import 'package:gestiap/features/technicien/data/models/equipements_model.dart';
import 'package:gestiap/features/technicien/providers/equipements_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; // Pour le CustomBottomNavigationBar
import 'package:intl/intl.dart';

class EquipementPage extends StatefulWidget {
  const EquipementPage({Key? key}) : super(key: key);

  @override
  _EquipementPageState createState() => _EquipementPageState();
}

class _EquipementPageState extends State<EquipementPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  String _type = 'Ordinateur'; // Valeur par défaut
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _modeleController = TextEditingController();
  final TextEditingController _numeroSerieController = TextEditingController();
  DateTime _dateAchat = DateTime.now();
  String _etat = 'En service'; // Valeur par défaut
  int _currentPageIndex = 0;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final equipementProvider = Provider.of<EquipementProvider>(
      context,
      listen: false,
    );
    equipementProvider.getEquipements();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _marqueController.dispose();
    _modeleController.dispose();
    _numeroSerieController.dispose();
    super.dispose();
  }

  Future<void> _showFormDialog(
    BuildContext context, {
    EquipementModel? equipement,
  }) async {
    if (equipement != null) {
      _nomController.text = equipement.nom;
      _type = equipement.type;
      _marqueController.text = equipement.marque;
      _modeleController.text = equipement.modele;
      _numeroSerieController.text = equipement.numeroSerie;
      _dateAchat = equipement.dateAchat;
      _etat = equipement.etat;
    } else {
      _nomController.clear();
      _type = 'Ordinateur';
      _marqueController.clear();
      _modeleController.clear();
      _numeroSerieController.clear();
      _dateAchat = DateTime.now();
      _etat = 'En service';
    }

    const List<String> typesEquipements = [
      'Ordinateur',
      'Imprimante',
      'Scanner',
      'Routeur',
      'Serveur',
      'Autre',
    ];
    const List<String> etatsEquipements = [
      'En service',
      'En maintenance',
      'Réparé',
      'Réformé',
    ];

    await showDialog(
      context: context,
      builder: (context) {
        final equipementProvider = Provider.of<EquipementProvider>(
          context,
          listen: false,
        );
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                equipement == null
                    ? 'Ajouter un Équipement'
                    : 'Modifier un Équipement',
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(labelText: 'Nom'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nom de l\'équipement';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _type,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _type = newValue;
                            });
                          }
                        },
                        items:
                            typesEquipements.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Type d\'équipement',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le type d\'équipement';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _marqueController,
                        decoration: const InputDecoration(labelText: 'Marque'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer la marque';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _modeleController,
                        decoration: const InputDecoration(labelText: 'Modèle'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le modèle';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _numeroSerieController,
                        decoration: const InputDecoration(
                          labelText: 'Numéro de Série',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le numéro de série';
                          }
                          return null;
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Date Achat: ${_dateFormat.format(_dateAchat)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _dateAchat,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _dateAchat = selectedDate;
                            });
                          }
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _etat,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _etat = newValue;
                            });
                          }
                        },
                        items:
                            etatsEquipements.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        decoration: const InputDecoration(labelText: 'État'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer l\'état de l\'équipement';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (equipement == null) {
                        final newEquipement = EquipementModel(
                          id: DateTime.now().toString(),
                          nom: _nomController.text,
                          type: _type,
                          marque: _marqueController.text,
                          modele: _modeleController.text,
                          numeroSerie: _numeroSerieController.text,
                          dateAchat: _dateAchat,
                          etat: _etat,
                        );
                        await equipementProvider.addEquipement(newEquipement);
                      } else {
                        final updatedEquipement = EquipementModel(
                          id: equipement.id,
                          nom: _nomController.text,
                          type: _type,
                          marque: _marqueController.text,
                          modele: _modeleController.text,
                          numeroSerie: _numeroSerieController.text,
                          dateAchat: _dateAchat,
                          etat: _etat,
                        );
                        await equipementProvider.updateEquipement(
                          updatedEquipement,
                        );
                      }
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            equipement == null
                                ? 'Équipement ajouté avec succès'
                                : 'Équipement modifié avec succès',
                          ),
                          duration: const Duration(seconds: 2),
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
      },
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    EquipementModel equipement,
  ) async {
    final equipementProvider = Provider.of<EquipementProvider>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cet équipement ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await equipementProvider.deleteEquipement(equipement.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Équipement supprimé avec succès'),
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

  @override
  Widget build(BuildContext context) {
    final equipementProvider = Provider.of<EquipementProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Équipements'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Liste des Équipements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildList(equipementProvider)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showFormDialog(context),
              child: const Text('Ajouter un Équipement'),
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
    );
  }

  Widget _buildList(EquipementProvider equipementProvider) {
    if (equipementProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (equipementProvider.error != null) {
      return Center(
        child: Text(
          'Erreur: ${equipementProvider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (equipementProvider.equipements.isEmpty) {
      return const Center(child: Text('Aucun équipement trouvé.'));
    } else {
      return ListView.builder(
        itemCount: equipementProvider.equipements.length,
        itemBuilder: (context, index) {
          final equipement = equipementProvider.equipements[index];
          return _buildListItem(context, equipement);
        },
      );
    }
  }

  Widget _buildListItem(BuildContext context, EquipementModel equipement) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: ${equipement.nom}'),
            Text('Type: ${equipement.type}'),
            Text('Marque: ${equipement.marque}'),
            Text('Modèle: ${equipement.modele}'),
            Text('Numéro de Série: ${equipement.numeroSerie}'),
            Text('Date Achat: ${_dateFormat.format(equipement.dateAchat)}'),
            Text('État: ${equipement.etat}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed:
                      () => _showFormDialog(context, equipement: equipement),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, equipement),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
