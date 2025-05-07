import 'package:flutter/material.dart';
import 'package:gestiap/features/rh/data/models/conges_model.dart';
import 'package:gestiap/features/rh/data/models/employes_model.dart';
import 'package:gestiap/features/rh/providers/conge_provider.dart';
import 'package:gestiap/features/rh/providers/employe_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; //Pour les CustomBottomNavigationBar
import 'package:intl/intl.dart'; // Pour la formattage de la date

class CongesPage extends StatefulWidget {
  const CongesPage({Key? key}) : super(key: key);

  @override
  _CongesPageState createState() => _CongesPageState();
}

class _CongesPageState extends State<CongesPage> {
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Charger les congés et les employés au démarrage de la page.
    // Assurez-vous que les providers sont correctement initialisés dans votre main.dart
    Provider.of<CongeProvider>(context, listen: false).getConges();
    Provider.of<EmployeProvider>(context, listen: false).getEmployes();
  }

  @override
  Widget build(BuildContext context) {
    final congesProvider = Provider.of<CongeProvider>(context);
    final employesProvider = Provider.of<EmployeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Congés'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Liste des Congés',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildCongeList(congesProvider, employesProvider)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showAddCongeDialog(context, congesProvider, employesProvider);
              },
              child: const Text('Demander un congé'),
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

  Widget _buildCongeList(
    CongeProvider congesProvider,
    EmployeProvider employesProvider,
  ) {
    if (congesProvider.loading || employesProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (congesProvider.conges.isEmpty) {
      return const Center(child: Text('Aucun congé trouvé.'));
    } else {
      return ListView.builder(
        itemCount: congesProvider.conges.length,
        itemBuilder: (context, index) {
          final CongeModel conge = congesProvider.conges[index];
          return FutureBuilder<EmployeModel?>(
            // Utilisation de FutureBuilder
            future: employesProvider.getEmployeById(conge.employeId),
            builder: (
              BuildContext context,
              AsyncSnapshot<EmployeModel?> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  title: Text('Chargement de l\'employé...'),
                ); // Afficher un indicateur de chargement pendant l'attente
              } else if (snapshot.hasError) {
                return ListTile(
                  title: Text(
                    'Erreur lors du chargement de l\'employé: ${snapshot.error}',
                  ),
                ); // Afficher une erreur si la Future échoue
              } else {
                final EmployeModel? employe = snapshot.data;
                return _buildCongeListItem(
                  conge,
                  employe,
                  congesProvider,
                  employesProvider,
                );
              }
            },
          );
        },
      );
    }
  }

  Widget _buildCongeListItem(
    CongeModel conge,
    EmployeModel? employe,
    CongeProvider congesProvider,
    EmployeProvider employesProvider,
  ) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String formattedDateDebut = formatter.format(conge.dateDebut);
    final String formattedDateFin = formatter.format(conge.dateFin);
    final String employeName = employe?.nom ?? 'Non trouvé';

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
                  'ID: ${conge.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Type: ${conge.typeConge}'),
                Text('Date début: $formattedDateDebut'),
                Text('Date fin: $formattedDateFin'),
                Text('Motif: ${conge.motif}'),
                Text('Statut: ${conge.statut}'),
                Text('Employé: $employeName'),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditCongeDialog(
                      context,
                      conge,
                      congesProvider,
                      employesProvider,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteCongeDialog(context, conge.id!, congesProvider);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCongeDialog(
    BuildContext context,
    CongeProvider congesProvider,
    EmployeProvider employesProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    String typeConge = '';
    DateTime dateDebut = DateTime.now();
    DateTime dateFin = DateTime.now();
    String motif = '';
    String statut = 'En attente';
    String? selectedEmployeId; // Pour stocker l'ID de l'employé sélectionné
    List<EmployeModel> employesList = employesProvider.employes;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Demander un congé'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Type de congé',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un type de congé';
                      }
                      return null;
                    },
                    onSaved: (value) => typeConge = value!,
                  ),
                  Row(
                    children: <Widget>[
                      const Text('Date début: '),
                      Text(DateFormat('dd/MM/yyyy').format(dateDebut)),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: dateDebut,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              dateDebut = selectedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Text('Date fin: '),
                      Text(DateFormat('dd/MM/yyyy').format(dateFin)),
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
                            setState(() {
                              dateFin = selectedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Motif'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un motif';
                      }
                      return null;
                    },
                    onSaved: (value) => motif = value!,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Employé'),
                    value: selectedEmployeId,
                    items:
                        employesList.map((EmployeModel employe) {
                          return DropdownMenuItem<String>(
                            value: employe.id,
                            child: Text(employe.nom),
                          );
                        }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Veuillez sélectionner un employé';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      selectedEmployeId = value;
                    },
                    onSaved: (value) => selectedEmployeId = value!,
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
                  if (selectedEmployeId != null) {
                    final newConge = CongeModel(
                      id: DateTime.now().toString(),
                      typeConge: typeConge,
                      dateDebut: dateDebut,
                      dateFin: dateFin,
                      motif: motif,
                      statut: statut,
                      employeId: selectedEmployeId!,
                    );
                    congesProvider.addConge(newConge);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Congé demandé avec succès!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez sélectionner un employé.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCongeDialog(
    BuildContext context,
    CongeModel congeAModifier,
    CongeProvider congesProvider,
    EmployeProvider employesProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    String typeConge = congeAModifier.typeConge;
    DateTime dateDebut = congeAModifier.dateDebut;
    DateTime dateFin = congeAModifier.dateFin;
    String motif = congeAModifier.motif;
    String statut = congeAModifier.statut;
    String? selectedEmployeId = congeAModifier.employeId;
    List<EmployeModel> employesList = employesProvider.employes;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier un congé'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: congeAModifier.typeConge,
                    decoration: const InputDecoration(
                      labelText: 'Type de congé',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un type de congé';
                      }
                      return null;
                    },
                    onSaved: (value) => typeConge = value!,
                  ),
                  Row(
                    children: <Widget>[
                      const Text('Date début: '),
                      Text(DateFormat('dd/MM/yyyy').format(dateDebut)),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: dateDebut,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              dateDebut = selectedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Text('Date fin: '),
                      Text(DateFormat('dd/MM/yyyy').format(dateFin)),
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
                            setState(() {
                              dateFin = selectedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  TextFormField(
                    initialValue: congeAModifier.motif,
                    decoration: const InputDecoration(labelText: 'Motif'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un motif';
                      }
                      return null;
                    },
                    onSaved: (value) => motif = value!,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Employé'),
                    value: selectedEmployeId,
                    items:
                        employesList.map((EmployeModel employe) {
                          return DropdownMenuItem<String>(
                            value: employe.id,
                            child: Text(employe.nom),
                          );
                        }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Veuillez sélectionner un employé';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      selectedEmployeId = value;
                    },
                    onSaved: (value) => selectedEmployeId = value!,
                  ),
                  TextFormField(
                    initialValue: congeAModifier.statut,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le statut du congé';
                      }
                      return null;
                    },
                    onSaved: (value) => statut = value!,
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
                  if (selectedEmployeId != null) {
                    final updatedConge = CongeModel(
                      id: congeAModifier.id,
                      typeConge: typeConge,
                      dateDebut: dateDebut,
                      dateFin: dateFin,
                      motif: motif,
                      statut: statut,
                      employeId: selectedEmployeId!,
                    );
                    congesProvider.updateConge(updatedConge);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Congé modifié avec succès!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez sélectionner un employé.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCongeDialog(
    BuildContext context,
    String congeId,
    CongeProvider congesProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer un congé'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce congé ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                congesProvider.deleteConge(congeId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Congé supprimé avec succès!'),
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
