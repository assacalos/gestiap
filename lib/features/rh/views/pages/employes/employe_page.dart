import 'package:flutter/material.dart';
import 'package:gestiap/features/rh/data/models/employes_model.dart';
import 'package:gestiap/features/rh/providers/employe_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; // Pour le CustomBottomNavigationBar
import 'package:intl/intl.dart';

class EmployePage extends StatefulWidget {
  const EmployePage({Key? key}) : super(key: key);

  @override
  _EmployePageState createState() => _EmployePageState();
}

class _EmployePageState extends State<EmployePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _posteController = TextEditingController();
  final TextEditingController _departementController = TextEditingController();
  DateTime _dateEmbauche = DateTime.now();
  int _currentPageIndex = 0;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final employeProvider = Provider.of<EmployeProvider>(
      context,
      listen: false,
    );
    employeProvider.getEmployes();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _posteController.dispose();
    _departementController.dispose();
    super.dispose();
  }

  Future<void> _showFormDialog(
    BuildContext context, {
    EmployeModel? employe,
  }) async {
    if (employe != null) {
      _nomController.text = employe.nom;
      _prenomController.text = employe.prenom;
      _emailController.text = employe.email;
      _telephoneController.text = employe.telephone;
      _posteController.text = employe.poste;
      _departementController.text = employe.departement;
      _dateEmbauche = employe.dateEmbauche;
    } else {
      _nomController.clear();
      _prenomController.clear();
      _emailController.clear();
      _telephoneController.clear();
      _posteController.clear();
      _departementController.clear();
      _dateEmbauche = DateTime.now();
    }

    await showDialog(
      context: context,
      builder: (context) {
        final employeProvider = Provider.of<EmployeProvider>(
          context,
          listen: false,
        );
        return AlertDialog(
          title: Text(
            employe == null ? 'Ajouter un Employé' : 'Modifier un Employé',
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
                        return 'Veuillez entrer le nom';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _prenomController,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le prénom';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer l\'email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _telephoneController,
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le numéro de téléphone';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _posteController,
                    decoration: const InputDecoration(labelText: 'Poste'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le poste';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _departementController,
                    decoration: const InputDecoration(labelText: 'Département'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le département';
                      }
                      return null;
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Date Embauche: ${_dateFormat.format(_dateEmbauche)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _dateEmbauche,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _dateEmbauche = selectedDate;
                        });
                      }
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
                  if (employe == null) {
                    final newEmploye = EmployeModel(
                      id: DateTime.now().toString(),
                      nom: _nomController.text,
                      prenom: _prenomController.text,
                      email: _emailController.text,
                      telephone: _telephoneController.text,
                      poste: _posteController.text,
                      departement: _departementController.text,
                      dateEmbauche: _dateEmbauche,
                    );
                    await employeProvider.addEmploye(newEmploye);
                  } else {
                    final updatedEmploye = EmployeModel(
                      id: employe.id,
                      nom: _nomController.text,
                      prenom: _prenomController.text,
                      email: _emailController.text,
                      telephone: _telephoneController.text,
                      poste: _posteController.text,
                      departement: _departementController.text,
                      dateEmbauche: _dateEmbauche,
                    );
                    await employeProvider.updateEmploye(updatedEmploye);
                  }
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        employe == null
                            ? 'Employé ajouté avec succès'
                            : 'Employé modifié avec succès',
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
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    EmployeModel employe,
  ) async {
    final employeProvider = Provider.of<EmployeProvider>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cet employé ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await employeProvider.deleteEmploye(employe.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Employé supprimé avec succès'),
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
    final employeProvider = Provider.of<EmployeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Employés'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Liste des Employés',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildList(employeProvider)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showFormDialog(context),
              child: const Text('Ajouter un Employé'),
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

  Widget _buildList(EmployeProvider employeProvider) {
    if (employeProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (employeProvider.error != null) {
      return Center(
        child: Text(
          'Erreur: ${employeProvider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (employeProvider.employes.isEmpty) {
      return const Center(child: Text('Aucun employé trouvé.'));
    } else {
      return ListView.builder(
        itemCount: employeProvider.employes.length,
        itemBuilder: (context, index) {
          final employe = employeProvider.employes[index];
          return _buildListItem(context, employe);
        },
      );
    }
  }

  Widget _buildListItem(BuildContext context, EmployeModel employe) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: ${employe.nom}'),
            Text('Prénom: ${employe.prenom}'),
            Text('Email: ${employe.email}'),
            Text('Téléphone: ${employe.telephone}'),
            Text('Poste: ${employe.poste}'),
            Text('Département: ${employe.departement}'),
            Text('Date Embauche: ${_dateFormat.format(employe.dateEmbauche)}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showFormDialog(context, employe: employe),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, employe),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
