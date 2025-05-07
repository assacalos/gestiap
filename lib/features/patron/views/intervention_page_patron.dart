import 'package:flutter/material.dart';
import 'package:gestiap/features/technicien/data/models/interventions_model.dart';
import 'package:gestiap/features/technicien/providers/interventions_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; //Pour les CustomBottomNavigationBar
import 'package:intl/intl.dart'; // Pour la formattage de la date

class InterventionsPage extends StatefulWidget {
  const InterventionsPage({Key? key}) : super(key: key);

  @override
  _InterventionsPageState createState() => _InterventionsPageState();
}

class _InterventionsPageState extends State<InterventionsPage> {
  int _currentPageIndex = 0; // Indice de la page actuelle pour la navigation
  // Pas besoin d'un ChangeNotifierProvider ici, il doit être au-dessus dans l'arbre des widgets
  @override
  void initState() {
    super.initState();
    // La logique d'initialisation du provider doit être dans le main.dart ou un parent
    final interventionsProvider = Provider.of<InterventionProvider>(
      context,
      listen: false,
    );
    interventionsProvider
        .getInterventions(); // Charger les interventions au démarrage de la page.
  }

  @override
  Widget build(BuildContext context) {
    // Consolider l'accès au InterventionsProvider
    final interventionsProvider = Provider.of<InterventionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Interventions'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Utilisation d'une Column pour organiser les éléments de la page
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Liste des Interventions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Affichage de la liste des interventions
            Expanded(
              // Utilisation de Expanded pour que la ListView occupe l'espace restant
              child: _buildInterventionList(interventionsProvider),
            ),
            const SizedBox(height: 20),
            //Bouton d'ajout d'intervention
            ElevatedButton(
              onPressed: () {
                _showAddInterventionDialog(context, interventionsProvider);
              },
              child: const Text('Ajouter une intervention'),
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

  // Méthode pour construire la liste des interventions
  Widget _buildInterventionList(InterventionProvider interventionsProvider) {
    if (interventionsProvider.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Afficher un loader pendant le chargement
    } else if (interventionsProvider.interventions.isEmpty) {
      return const Center(
        child: Text('Aucune intervention trouvée.'),
      ); // Message si la liste est vide.
    } else {
      return ListView.builder(
        itemCount: interventionsProvider.interventions.length,
        itemBuilder: (context, index) {
          final InterventionModel intervention =
              interventionsProvider.interventions[index];
          return _buildInterventionListItem(
            intervention,
            interventionsProvider,
          );
        },
      );
    }
  }

  // Méthode pour construire chaque élément de la liste
  Widget _buildInterventionListItem(
    InterventionModel intervention,
    InterventionProvider interventionsProvider,
  ) {
    // DateFormat pour formater la date
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    final String formattedDateIntervention = formatter.format(
      intervention.dateIntervention,
    );
    //final String formattedDateFin = formatter.format(intervention.dateFin);

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
                  'ID: ${intervention.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Stock: ${intervention.stockId}'),
                Text('Client: ${intervention.clientId}'),
                Text('Date intervention: $formattedDateIntervention'),
                Text('Description: ${intervention.description}'),
                Text('Technicien: ${intervention.technicien}'),
                // Text('Client: ${intervention.client}'),
                Text('Statut: ${intervention.statut}'),
                Text('Rapport: ${intervention.rapport}'),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditInterventionDialog(
                      context,
                      intervention,
                      interventionsProvider,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteInterventionDialog(
                      context,
                      intervention.id,
                      interventionsProvider,
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

  // Méthode pour afficher la boîte de dialogue d'ajout d'intervention
  void _showAddInterventionDialog(
    BuildContext context,
    InterventionProvider interventionsProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    String stockId = '';
    String stockName = '';
    String clientId = '';
    String clientEntreprise = '';
    DateTime dateIntervention = DateTime.now();
    String description = '';
    String technicien = '';
    String statut = '';
    String rapport = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une intervention'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Type d\'intervention',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un type d\'intervention';
                      }
                      return null;
                    },
                    onSaved: (value) => stockName = value!,
                  ),
                  // Utilisation de showDatePicker pour la sélection de la date
                  Row(
                    children: <Widget>[
                      const Text('Date début: '),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(dateIntervention),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: dateIntervention,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            // Afficher aussi l'heure
                            final TimeOfDay? selectedTime =
                                await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                    dateIntervention,
                                  ),
                                );
                            if (selectedTime != null) {
                              setState(() {
                                dateIntervention = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  /* Row(
                    children: <Widget>[
                      const Text('Date fin: '),
                      Text(DateFormat('dd/MM/yyyy HH:mm').format(dateFin)),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: dateFin,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            // Afficher aussi l'heure
                            final TimeOfDay? selectedTime =
                                await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(dateFin),
                                );
                            if (selectedTime != null) {
                              setState(() {
                                dateFin = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ], */
                  // ),
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
                    decoration: const InputDecoration(labelText: 'Technicien'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un technicien';
                      }
                      return null;
                    },
                    onSaved: (value) => technicien = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Client'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un client';
                      }
                      return null;
                    },
                    onSaved: (value) => clientId = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Statut'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un statut';
                      }
                      return null;
                    },
                    onSaved: (value) => statut = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Rapport'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un rapport';
                      }
                      return null;
                    },
                    onSaved: (value) => rapport = value!,
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
                  final newIntervention = InterventionModel(
                    id: DateTime.now().toString(), // Générer un ID unique
                    stockId: stockId,
                    stockName: stockName,
                    clientName: clientEntreprise,
                    clientId: clientId,
                    dateIntervention: dateIntervention,
                    titre: stockName,
                    description: description,
                    technicien: technicien,
                    statut: statut,
                    rapport: rapport,
                  );
                  interventionsProvider.addIntervention(
                    newIntervention,
                  ); // Utiliser la méthode du provider
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Intervention ajoutée avec succès!'),
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

  // Méthode pour afficher la boîte de dialogue de modification d'intervention
  void _showEditInterventionDialog(
    BuildContext context,
    InterventionModel interventionAModifier,
    InterventionProvider interventionsProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    String stockId = interventionAModifier.stockId;
    DateTime dateIntervention = interventionAModifier.dateIntervention;
    String titre = interventionAModifier.titre;
    String description = interventionAModifier.description;
    String technicien = interventionAModifier.technicien;
    String clientId = interventionAModifier.clientId;
    String statut = interventionAModifier.statut;

    String rapport = interventionAModifier.rapport ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier une intervention'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: interventionAModifier.stockId,
                    decoration: const InputDecoration(labelText: 'Stock ID'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un type d\'intervention';
                      }
                      return null;
                    },
                    onSaved: (value) => stockId = value!,
                  ),
                  TextFormField(
                    initialValue: interventionAModifier.clientId,
                    decoration: const InputDecoration(labelText: 'Client ID'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un client ID';
                      }
                      return null;
                    },
                    onSaved: (value) => clientId = value!,
                  ),
                  TextFormField(
                    initialValue: interventionAModifier.titre,
                    decoration: const InputDecoration(labelText: 'Titre'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un titre';
                      }
                      return null;
                    },
                    onSaved: (value) => titre = value!,
                  ),
                  // Utilisation de showDatePicker pour la sélection de la date
                  Row(
                    children: <Widget>[
                      const Text('Date début: '),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(dateIntervention),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: dateIntervention,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            // Afficher aussi l'heure
                            final TimeOfDay? selectedTime =
                                await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                    dateIntervention,
                                  ),
                                );
                            if (selectedTime != null) {
                              setState(() {
                                dateIntervention = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),

                  TextFormField(
                    initialValue: interventionAModifier.description,
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
                    initialValue: interventionAModifier.technicien,
                    decoration: const InputDecoration(labelText: 'Technicien'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un technicien';
                      }
                      return null;
                    },
                    onSaved: (value) => technicien = value!,
                  ),

                  TextFormField(
                    initialValue: interventionAModifier.statut,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un statut';
                      }
                      return null;
                    },
                    onSaved: (value) => statut = value!,
                  ),
                  TextFormField(
                    initialValue: interventionAModifier.rapport,
                    decoration: const InputDecoration(labelText: 'Rapport'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un rapport';
                      }
                      return null;
                    },
                    onSaved: (value) => rapport = value!,
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
                  // Mettre à jour l'intervention
                  final updatedIntervention = InterventionModel(
                    id: interventionAModifier.id, // Garder le même ID
                    stockId: stockId,
                    clientId: clientId,
                    dateIntervention: dateIntervention,
                    titre: titre,
                    description: description,
                    technicien: technicien,
                    statut: statut,
                    rapport: rapport,
                  );
                  interventionsProvider.updateIntervention(
                    updatedIntervention,
                  ); // Utiliser la méthode update du provider

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Intervention modifiée avec succès!'),
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
  void _showDeleteInterventionDialog(
    BuildContext context,
    String interventionId,
    InterventionProvider interventionsProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer une intervention'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette intervention ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                interventionsProvider.deleteIntervention(
                  interventionId,
                ); // Utiliser la méthode delete du provider
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Intervention supprimée avec succès!'),
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
