import 'package:flutter/material.dart';
import 'package:gestiap/features/technicien/data/models/rapport_intervention_model.dart';
import 'package:gestiap/features/technicien/providers/rapport_intervention_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; // Pour le CustomBottomNavigationBar
import 'package:intl/intl.dart';

class RapportInterventionPage extends StatefulWidget {
  const RapportInterventionPage({Key? key}) : super(key: key);

  @override
  _RapportInterventionPageState createState() =>
      _RapportInterventionPageState();
}

class _RapportInterventionPageState extends State<RapportInterventionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _interventionIdController =
      TextEditingController();
  DateTime _dateRapport = DateTime.now();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _conclusionController = TextEditingController();
  final TextEditingController _technicienController = TextEditingController();
  int _currentPageIndex = 0;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final rapportProvider = Provider.of<RapportInterventionProvider>(
      context,
      listen: false,
    );
    rapportProvider.getRapportsIntervention();
  }

  @override
  void dispose() {
    _interventionIdController.dispose();
    _descriptionController.dispose();
    _conclusionController.dispose();
    _technicienController.dispose();
    super.dispose();
  }

  Future<void> _showFormDialog(
    BuildContext context, {
    RapportInterventionModel? rapport,
  }) async {
    if (rapport != null) {
      _interventionIdController.text = rapport.interventionId;
      _dateRapport = rapport.dateRapport;
      _descriptionController.text = rapport.description;
      _conclusionController.text = rapport.conclusion;
      _technicienController.text = rapport.technicien;
    } else {
      _interventionIdController.clear();
      _dateRapport = DateTime.now();
      _descriptionController.clear();
      _conclusionController.clear();
      _technicienController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) {
        final rapportProvider = Provider.of<RapportInterventionProvider>(
          context,
          listen: false,
        );
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                rapport == null ? 'Ajouter un Rapport' : 'Modifier un Rapport',
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _interventionIdController,
                        decoration: const InputDecoration(
                          labelText: 'ID Intervention',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer l\'ID de l\'intervention';
                          }
                          return null;
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Date Rapport: ${_dateFormat.format(_dateRapport)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _dateRapport,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _dateRapport = selectedDate;
                            });
                          }
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
                      TextFormField(
                        controller: _conclusionController,
                        decoration: const InputDecoration(
                          labelText: 'Conclusion',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer la conclusion';
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
                      if (rapport == null) {
                        final newRapport = RapportInterventionModel(
                          id: DateTime.now().toString(),
                          interventionId: _interventionIdController.text,
                          dateRapport: _dateRapport,
                          description: _descriptionController.text,
                          conclusion: _conclusionController.text,
                          technicien: _technicienController.text,
                        );
                        await rapportProvider.addRapportIntervention(
                          newRapport,
                        );
                      } else {
                        final updatedRapport = RapportInterventionModel(
                          id: rapport.id,
                          interventionId: _interventionIdController.text,
                          dateRapport: _dateRapport,
                          description: _descriptionController.text,
                          conclusion: _conclusionController.text,
                          technicien: _technicienController.text,
                        );
                        await rapportProvider.updateRapportIntervention(
                          updatedRapport,
                        );
                      }
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            rapport == null
                                ? 'Rapport ajouté avec succès'
                                : 'Rapport modifié avec succès',
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
    RapportInterventionModel rapport,
  ) async {
    final rapportProvider = Provider.of<RapportInterventionProvider>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce rapport ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await rapportProvider.deleteRapportIntervention(rapport.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rapport supprimé avec succès'),
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
    final rapportProvider = Provider.of<RapportInterventionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports d\'Intervention'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Liste des Rapports d\'Intervention',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildList(rapportProvider)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showFormDialog(context),
              child: const Text('Ajouter un Rapport'),
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

  Widget _buildList(RapportInterventionProvider rapportProvider) {
    if (rapportProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (rapportProvider.error != null) {
      return Center(
        child: Text(
          'Erreur: ${rapportProvider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (rapportProvider.rapports.isEmpty) {
      return const Center(child: Text('Aucun rapport trouvé.'));
    } else {
      return ListView.builder(
        itemCount: rapportProvider.rapports.length,
        itemBuilder: (context, index) {
          final rapport = rapportProvider.rapports[index];
          return _buildListItem(context, rapport);
        },
      );
    }
  }

  Widget _buildListItem(
    BuildContext context,
    RapportInterventionModel rapport,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID Intervention: ${rapport.interventionId}'),
            Text('Date Rapport: ${_dateFormat.format(rapport.dateRapport)}'),
            Text('Description: ${rapport.description}'),
            Text('Conclusion: ${rapport.conclusion}'),
            Text('Technicien: ${rapport.technicien}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showFormDialog(context, rapport: rapport),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, rapport),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
