import 'package:flutter/material.dart';
import 'package:gestiap/features/rh/data/models/conges_model.dart';
import 'package:gestiap/features/rh/providers/conge_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; // Pour le CustomBottomNavigationBar
import 'package:intl/intl.dart';

class CongePage extends StatefulWidget {
  const CongePage({Key? key}) : super(key: key);

  @override
  _CongePageState createState() => _CongePageState();
}

class _CongePageState extends State<CongePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _employeIdController = TextEditingController();
  DateTime _dateDebut = DateTime.now();
  DateTime _dateFin = DateTime.now();
  String _typeConge = 'Congé payé'; // Valeur par défaut
  String _statut = 'En attente'; // Valeur par défaut
  final TextEditingController _motifController = TextEditingController();
  int _currentPageIndex = 0;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final congeProvider = Provider.of<CongeProvider>(context, listen: false);
    congeProvider.getConges();
  }

  @override
  void dispose() {
    _employeIdController.dispose();
    _motifController.dispose();
    super.dispose();
  }

  Future<void> _showFormDialog(
    BuildContext context, {
    CongeModel? conge,
  }) async {
    if (conge != null) {
      _employeIdController.text = conge.employeId;
      _dateDebut = conge.dateDebut;
      _dateFin = conge.dateFin;
      _typeConge = conge.typeConge;
      _statut = conge.statut;
      _motifController.text = conge.motif;
    } else {
      _employeIdController.clear();
      _dateDebut = DateTime.now();
      _dateFin = DateTime.now();
      _typeConge = 'Congé payé';
      _statut = 'En attente';
      _motifController.clear();
    }

    const List<String> typesConges = [
      'Congé payé',
      'Congé maladie',
      'Congé sans solde',
      'Autres',
    ];
    const List<String> statuts = ['En attente', 'Approuvé', 'Refusé'];

    await showDialog(
      context: context,
      builder: (context) {
        final congeProvider = Provider.of<CongeProvider>(
          context,
          listen: false,
        );
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                conge == null ? 'Demander un Congé' : 'Modifier un Congé',
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _employeIdController,
                        decoration: const InputDecoration(
                          labelText: 'ID Employé',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer l\'ID de l\'employé';
                          }
                          return null;
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Date Début: ${_dateFormat.format(_dateDebut)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _dateDebut,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _dateDebut = selectedDate;
                            });
                          }
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Date Fin: ${_dateFormat.format(_dateFin)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _dateFin,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _dateFin = selectedDate;
                            });
                          }
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _typeConge,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _typeConge = newValue;
                            });
                          }
                        },
                        items:
                            typesConges.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Type de Congé',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le type de congé';
                          }
                          return null;
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
                            statuts.map<DropdownMenuItem<String>>((
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
                            return 'Veuillez entrer le statut du congé';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _motifController,
                        decoration: const InputDecoration(labelText: 'Motif'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le motif du congé';
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
                      if (conge == null) {
                        final newConge = CongeModel(
                          id: DateTime.now().toString(),
                          employeId: _employeIdController.text,
                          dateDebut: _dateDebut,
                          dateFin: _dateFin,
                          typeConge: _typeConge,
                          statut: _statut,
                          motif: _motifController.text,
                        );
                        await congeProvider.addConge(newConge);
                      } else {
                        final updatedConge = CongeModel(
                          id: conge.id,
                          employeId: _employeIdController.text,
                          dateDebut: _dateDebut,
                          dateFin: _dateFin,
                          typeConge: _typeConge,
                          statut: _statut,
                          motif: _motifController.text,
                        );
                        await congeProvider.updateConge(updatedConge);
                      }
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            conge == null
                                ? 'Congé ajouté avec succès'
                                : 'Congé modifié avec succès',
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

  Future<void> _showDeleteDialog(BuildContext context, CongeModel conge) async {
    final congeProvider = Provider.of<CongeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette demande de congé ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await congeProvider.deleteConge(conge.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Congé supprimé avec succès'),
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
    final congeProvider = Provider.of<CongeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Congés'), centerTitle: true),
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
            Expanded(child: _buildList(congeProvider)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showFormDialog(context),
              child: const Text('Demander un Congé'),
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

  Widget _buildList(CongeProvider congeProvider) {
    if (congeProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (congeProvider.error != null) {
      return Center(
        child: Text(
          'Erreur: ${congeProvider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (congeProvider.conges.isEmpty) {
      return const Center(child: Text('Aucun congé trouvé.'));
    } else {
      return ListView.builder(
        itemCount: congeProvider.conges.length,
        itemBuilder: (context, index) {
          final conge = congeProvider.conges[index];
          return _buildListItem(context, conge);
        },
      );
    }
  }

  Widget _buildListItem(BuildContext context, CongeModel conge) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID Employé: ${conge.employeId}'),
            Text('Date Début: ${_dateFormat.format(conge.dateDebut)}'),
            Text('Date Fin: ${_dateFormat.format(conge.dateFin)}'),
            Text('Type de Congé: ${conge.typeConge}'),
            Text('Statut: ${conge.statut}'),
            Text('Motif: ${conge.motif}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showFormDialog(context, conge: conge),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, conge),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
