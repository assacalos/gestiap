import 'package:flutter/material.dart';
import 'package:gestiap/features/technicien/data/models/interventions_model.dart';
import 'package:gestiap/features/technicien/providers/interventions_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; // Pour le CustomBottomNavigationBar
import 'package:intl/intl.dart';

class InterventionPage extends StatefulWidget {
  const InterventionPage({Key? key}) : super(key: key);

  @override
  _InterventionPageState createState() => _InterventionPageState();
}

class _InterventionPageState extends State<InterventionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _dateIntervention = DateTime.now();
  String _statut = 'Planifiée'; // Valeur par défaut
  final TextEditingController _technicienController = TextEditingController();
  final TextEditingController _rapportController = TextEditingController();
  int _currentPageIndex = 0;

  // Pour la liste déroulante des statuts
  final List<String> _statuts = [
    'Planifiée',
    'En cours',
    'Terminée',
    'Annulée',
  ];

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final interventionProvider = Provider.of<InterventionProvider>(
      context,
      listen: false,
    );
    interventionProvider.getInterventions();
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _technicienController.dispose();
    _rapportController.dispose();
    super.dispose();
  }

  Future<void> _showFormDialog(
    BuildContext context, {
    InterventionModel? intervention,
  }) async {
    if (intervention != null) {
      _titreController.text = intervention.titre;
      _descriptionController.text = intervention.description;
      _dateIntervention = intervention.dateIntervention;
      _statut = intervention.statut;
      _technicienController.text = intervention.technicien;
      _rapportController.text = intervention.rapport ?? '';
    } else {
      _titreController.clear();
      _descriptionController.clear();
      _dateIntervention = DateTime.now();
      _statut = 'Planifiée';
      _technicienController.clear();
      _rapportController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) {
        final interventionProvider = Provider.of<InterventionProvider>(
          context,
          listen: false,
        );
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                intervention == null
                    ? 'Ajouter une Intervention'
                    : 'Modifier une Intervention',
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _titreController,
                        decoration: const InputDecoration(labelText: 'Titre'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le titre de l\'intervention';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer la description';
                          }
                          return null;
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Date Intervention: ${_dateFormat.format(_dateIntervention)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _dateIntervention,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _dateIntervention = selectedDate;
                            });
                          }
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _statut,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _statut = newValue;
                            });
                          }
                        },
                        items:
                            _statuts.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        decoration: const InputDecoration(labelText: 'Statut'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le statut';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _technicienController,
                        decoration: const InputDecoration(
                          labelText: 'Technicien',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nom du technicien';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _rapportController,
                        decoration: const InputDecoration(
                          labelText: 'Rapport (Optionnel)',
                        ),
                        maxLines: 3,
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
                      // Ici, vous devrez récupérer l'ID de l'équipement sélectionné
                      // Vous pouvez utiliser un DropdownButtonFormField pour la sélection
                      // de l'équipement et passer l'ID ici.  Pour simplifier, j'utilise une constante.
                      const String equipementId =
                          'equipementId'; // Remplacez par la logique réelle

                      if (intervention == null) {
                        final newIntervention = InterventionModel(
                          id: DateTime.now().toString(),
                          stockId: equipementId,
                          clientId:
                              'clientId', // Remplacez par la logique réelle
                          titre: _titreController.text,
                          description: _descriptionController.text,
                          dateIntervention: _dateIntervention,
                          statut: _statut,
                          technicien: _technicienController.text,
                          rapport: _rapportController.text,
                        );
                        await interventionProvider.addIntervention(
                          newIntervention,
                        );
                      } else {
                        final updatedIntervention = InterventionModel(
                          id: intervention.id,
                          stockId: intervention.stockId,
                          clientId: intervention.clientId,
                          titre: _titreController.text,
                          description: _descriptionController.text,
                          dateIntervention: _dateIntervention,
                          statut: _statut,
                          technicien: _technicienController.text,
                          rapport: _rapportController.text,
                        );
                        await interventionProvider.updateIntervention(
                          updatedIntervention,
                        );
                      }
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            intervention == null
                                ? 'Intervention ajoutée avec succès'
                                : 'Intervention modifiée avec succès',
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
    InterventionModel intervention,
  ) async {
    final interventionProvider = Provider.of<InterventionProvider>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette intervention ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await interventionProvider.deleteIntervention(intervention.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Intervention supprimée avec succès'),
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
    final interventionProvider = Provider.of<InterventionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Interventions'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Liste des Interventions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildList(interventionProvider)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showFormDialog(context),
              child: const Text('Ajouter une Intervention'),
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

  Widget _buildList(InterventionProvider interventionProvider) {
    if (interventionProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (interventionProvider.error != null) {
      return Center(
        child: Text(
          'Erreur: ${interventionProvider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (interventionProvider.interventions.isEmpty) {
      return const Center(child: Text('Aucune intervention trouvée.'));
    } else {
      return ListView.builder(
        itemCount: interventionProvider.interventions.length,
        itemBuilder: (context, index) {
          final intervention = interventionProvider.interventions[index];
          return _buildListItem(context, intervention);
        },
      );
    }
  }

  Widget _buildListItem(BuildContext context, InterventionModel intervention) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Titre: ${intervention.titre}'),
            Text('Description: ${intervention.description}'),
            Text(
              'Date Intervention: ${_dateFormat.format(intervention.dateIntervention)}',
            ),
            Text('Statut: ${intervention.statut}'),
            Text('Technicien: ${intervention.technicien}'),
            Text('Rapport: ${intervention.rapport ?? 'N/A'}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed:
                      () =>
                          _showFormDialog(context, intervention: intervention),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, intervention),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
