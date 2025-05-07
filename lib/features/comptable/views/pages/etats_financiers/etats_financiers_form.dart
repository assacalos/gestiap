import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/data/models/etat_financier_model.dart';
import 'package:gestiap/features/comptable/providers/etat_financier_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; //Pour le CustomBottomNavigationBar
import 'package:intl/intl.dart';

class EtatFinancierPage extends StatefulWidget {
  const EtatFinancierPage({Key? key}) : super(key: key);

  @override
  _EtatFinancierPageState createState() => _EtatFinancierPageState();
}

class _EtatFinancierPageState extends State<EtatFinancierPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _typeEtatController = TextEditingController();
  DateTime _dateDebut = DateTime.now();
  DateTime _dateFin = DateTime.now();
  final Map<String, TextEditingController> _donneesControllers = {};
  String _devise = 'FCFA'; // Valeur par défaut
  int _currentPageIndex = 0;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final etatFinancierProvider = Provider.of<EtatFinancierProvider>(
      context,
      listen: false,
    );
    etatFinancierProvider.getEtatsFinanciers();
  }

  @override
  void dispose() {
    _typeEtatController.dispose();
    _donneesControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _showFormDialog(
    BuildContext context, {
    EtatFinancierModel? etatFinancier,
  }) async {
    if (etatFinancier != null) {
      _typeEtatController.text = etatFinancier.typeEtat;
      _dateDebut = etatFinancier.dateDebut;
      _dateFin = etatFinancier.dateFin;
      _devise = etatFinancier.devise;
      _donneesControllers.clear();
      etatFinancier.donnees.forEach((key, value) {
        _donneesControllers[key] = TextEditingController(
          text: value.toString(),
        );
      });
    } else {
      _typeEtatController.clear();
      _dateDebut = DateTime.now();
      _dateFin = DateTime.now();
      _devise = 'FCFA';
      _donneesControllers.clear();
    }

    // Définir les options pour le type d'état et la devise
    const List<String> typesEtats = [
      'Bilan',
      'Compte de Résultat',
      'Tableau de Flux de Trésorerie',
    ];
    const List<String> devises = ['FCFA', 'USD', 'EUR', 'GBP'];

    await showDialog(
      context: context,
      builder: (context) {
        final etatFinancierProvider = Provider.of<EtatFinancierProvider>(
          context,
          listen: false,
        );
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                etatFinancier == null
                    ? 'Ajouter un État Financier'
                    : 'Modifier un État Financier',
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _typeEtatController.text,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _typeEtatController.text = newValue;
                            });
                          }
                        },

                        items:
                            typesEtats.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Type d\'état',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le type d\'état';
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
                        value: _devise,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _devise = newValue;
                            });
                          }
                        },
                        items:
                            devises.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        decoration: const InputDecoration(labelText: 'Devise'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer la devise';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Données Financières',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Ajoutez les postes et leurs montants.  Ex: "Chiffre d\'affaires:10000"',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      ..._buildDonneesFields(setState),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            final String nouveauPoste =
                                'Poste ${_donneesControllers.length + 1}';
                            _donneesControllers[nouveauPoste] =
                                TextEditingController();
                          });
                        },
                        child: const Text('Ajouter un Poste'),
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
                      final Map<String, double> donnees = {};
                      _donneesControllers.forEach((key, controller) {
                        final value = double.tryParse(controller.text);
                        if (value != null) {
                          donnees[key] = value;
                        } else {
                          // Gestion d'erreur : afficher un message à l'utilisateur
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Valeur invalide pour le poste "$key". Veuillez entrer un nombre.',
                              ),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          return; // Arrêter l'enregistrement
                        }
                      });

                      if (etatFinancier == null) {
                        final newEtatFinancier = EtatFinancierModel(
                          id: DateTime.now().toString(),
                          typeEtat: _typeEtatController.text,
                          dateDebut: _dateDebut,
                          dateFin: _dateFin,
                          donnees: donnees,
                          devise: _devise,
                        );
                        await etatFinancierProvider.addEtatFinancier(
                          newEtatFinancier,
                        );
                      } else {
                        final updatedEtatFinancier = EtatFinancierModel(
                          id: etatFinancier.id,
                          typeEtat: _typeEtatController.text,
                          dateDebut: _dateDebut,
                          dateFin: _dateFin,
                          donnees: donnees,
                          devise: _devise,
                        );
                        await etatFinancierProvider.updateEtatFinancier(
                          updatedEtatFinancier,
                        );
                      }
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            etatFinancier == null
                                ? 'État financier ajouté avec succès'
                                : 'État financier modifié avec succès',
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

  List<Widget> _buildDonneesFields(StateSetter setState) {
    return _donneesControllers.entries.map((entry) {
      final key = entry.key;
      final controller = entry.value;
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: key),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une valeur pour $key';
                }
                if (double.tryParse(value) == null) {
                  return 'Valeur invalide';
                }
                return null;
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _donneesControllers.remove(key);
              });
            },
          ),
        ],
      );
    }).toList();
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    EtatFinancierModel etatFinancier,
  ) async {
    final etatFinancierProvider = Provider.of<EtatFinancierProvider>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cet état financier ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await etatFinancierProvider.deleteEtatFinancier(
                  etatFinancier.id,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('État financier supprimé avec succès'),
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
    final etatFinancierProvider = Provider.of<EtatFinancierProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('États Financiers'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Liste des États Financiers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildList(etatFinancierProvider)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showFormDialog(context),
              child: const Text('Ajouter un État Financier'),
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

  Widget _buildList(EtatFinancierProvider etatFinancierProvider) {
    if (etatFinancierProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (etatFinancierProvider.error != null) {
      return Center(
        child: Text(
          'Erreur: ${etatFinancierProvider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (etatFinancierProvider.etatsFinanciers.isEmpty) {
      return const Center(child: Text('Aucun état financier trouvé.'));
    } else {
      return ListView.builder(
        itemCount: etatFinancierProvider.etatsFinanciers.length,
        itemBuilder: (context, index) {
          final etatFinancier = etatFinancierProvider.etatsFinanciers[index];
          return _buildListItem(context, etatFinancier);
        },
      );
    }
  }

  Widget _buildListItem(
    BuildContext context,
    EtatFinancierModel etatFinancier,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              etatFinancier.typeEtat,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Date Début: ${_dateFormat.format(etatFinancier.dateDebut)}'),
            Text('Date Fin: ${_dateFormat.format(etatFinancier.dateFin)}'),
            Text('Devise: ${etatFinancier.devise}'),
            const SizedBox(height: 8),
            const Text(
              'Données Financières:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // Afficher les données financières
            ...etatFinancier.donnees.entries.map((entry) {
              return Text('${entry.key}: ${entry.value}');
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed:
                      () => _showFormDialog(
                        context,
                        etatFinancier: etatFinancier,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, etatFinancier),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
