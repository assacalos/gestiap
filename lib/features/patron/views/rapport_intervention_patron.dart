/* import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/parc_auto/providers/rapport_intervention_provider.dart'; // Assurez-vous du chemin
import 'package:gestiap/models/rapport_intervention_model.dart'; // Assurez-vous du chemin
import 'package:gestiap/core/widgets/widgets_widgets.dart'; //Pour le CustomBottomNavigationBar

class RapportInterventionPage extends StatefulWidget {
  const RapportInterventionPage({Key? key}) : super(key: key);

  @override
  _RapportInterventionPageState createState() =>
      _RapportInterventionPageState();
}/*  */

class _RapportInterventionPageState extends State<RapportInterventionPage> {
  // Pas besoin d'un ChangeNotifierProvider ici, il doit être au-dessus dans l'arbre des widgets
  @override
  void initState() {
    super.initState();
    // La logique d'initialisation du provider doit être dans le main.dart ou un parent
    // final rapportProvider = Provider.of<RapportInterventionProvider>(context, listen: false);
    // rapportProvider.getRapports(); // Charger les rapports au démarrage de la page.
  }

  @override
  Widget build(BuildContext context) {
    // Consolider l'accès au RapportInterventionProvider
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
              'Liste des Rapports',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildRapportList(rapportProvider)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showAddRapportDialog(context, rapportProvider);
              },
              child: const Text('Ajouter un Rapport'),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          const CustomBottomNavigationBar(), // Assurez-vous que c'est correct
    );
  }

  Widget _buildRapportList(RapportInterventionProvider rapportProvider) {
    if (rapportProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (rapportProvider.rapports.isEmpty) {
      return const Center(child: Text('Aucun rapport trouvé.'));
    } else {
      return ListView.builder(
        itemCount: rapportProvider.rapports.length,
        itemBuilder: (context, index) {
          final RapportInterventionModel rapport =
              rapportProvider.rapports[index];
          return _buildRapportListItem(rapport, rapportProvider);
        },
      );
    }
  }

  Widget _buildRapportListItem(
    RapportInterventionModel rapport,
    RapportInterventionProvider rapportProvider,
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
                  'ID: ${rapport.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Date: ${rapport.date}'),
                Text('Description: ${rapport.description}'),
                Text('État: ${rapport.etatIntervention}'),
                Text('ID Véhicule: ${rapport.idVehicule}'), // Ajout
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditRapportDialog(
                      context,
                      rapportProvider.rapports, // Passer la liste
                      rapport,
                      rapportProvider,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteRapportDialog(
                      context,
                      rapport.id,
                      rapportProvider,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRapportDialog(
    BuildContext context,
    RapportInterventionProvider rapportProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    DateTime date = DateTime.now();
    String description = '';
    String etatIntervention = '';
    String idVehicule = ''; // Ajout

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un Rapport'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  StatefulBuilder(
                    builder: (context, setState) {
                      return ListTile(
                        title: Text('Date: ${date.toLocal()}'.split(' ')[0]),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              date = selectedDate;
                            });
                          }
                        },
                      );
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une description';
                      }
                      return null;
                    },
                    onSaved: (value) => description = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'État Intervention',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un état';
                      }
                      return null;
                    },
                    onSaved: (value) => etatIntervention = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'ID Véhicule',
                    ), //Ajout
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer l\'ID du véhicule';
                      }
                      return null;
                    },
                    onSaved: (value) => idVehicule = value!,
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
                  final newRapport = RapportInterventionModel(
                    id: DateTime.now().toString(),
                    date: date,
                    description: description,
                    etatIntervention: etatIntervention,
                    idVehicule: idVehicule, // Ajout
                  );
                  rapportProvider.addRapport(newRapport);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rapport ajouté avec succès!'),
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

  void _showEditRapportDialog(
    BuildContext context,
    List<RapportInterventionModel> rapports,
    RapportInterventionModel rapportAModifier,
    RapportInterventionProvider rapportProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    DateTime date = rapportAModifier.date;
    String description = rapportAModifier.description;
    String etatIntervention = rapportAModifier.etatIntervention;
    String idVehicule = rapportAModifier.idVehicule; // Ajout

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier un Rapport'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  StatefulBuilder(
                    builder: (context, setState) {
                      return ListTile(
                        title: Text('Date: ${date.toLocal()}'.split(' ')[0]),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              date = selectedDate;
                            });
                          }
                        },
                      );
                    },
                  ),
                  TextFormField(
                    initialValue: rapportAModifier.description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une description';
                      }
                      return null;
                    },
                    onSaved: (value) => description = value!,
                  ),
                  TextFormField(
                    initialValue: rapportAModifier.etatIntervention,
                    decoration: const InputDecoration(
                      labelText: 'État Intervention',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un état';
                      }
                      return null;
                    },
                    onSaved: (value) => etatIntervention = value!,
                  ),
                  TextFormField(
                    initialValue: rapportAModifier.idVehicule, // Ajout
                    decoration: const InputDecoration(labelText: 'ID Véhicule'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer l\'ID du véhicule';
                      }
                      return null;
                    },
                    onSaved: (value) => idVehicule = value!,
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
                  final updatedRapport = RapportInterventionModel(
                    id: rapportAModifier.id,
                    date: date,
                    description: description,
                    etatIntervention: etatIntervention,
                    idVehicule: idVehicule, // Ajout
                  );
                  rapportProvider.updateRapport(updatedRapport);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rapport modifié avec succès!'),
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

  void _showDeleteRapportDialog(
    BuildContext context,
    String rapportId,
    RapportInterventionProvider rapportProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer un Rapport'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce rapport ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                rapportProvider.deleteRapport(rapportId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rapport supprimé avec succès!'),
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
 */
