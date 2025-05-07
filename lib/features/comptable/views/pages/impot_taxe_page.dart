import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/data/models/impot_taxes_model.dart';
import 'package:gestiap/features/comptable/providers/impot_taxe_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; //Pour le CustomBottomNavigationBar
import 'package:intl/intl.dart'; // Pour la formattage de la date

class ImpotTaxePage extends StatefulWidget {
  const ImpotTaxePage({Key? key}) : super(key: key);

  @override
  _ImpotTaxePageState createState() => _ImpotTaxePageState();
}

class _ImpotTaxePageState extends State<ImpotTaxePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  DateTime _dateDeclaration = DateTime.now();
  DateTime _datePaiement = DateTime.now();
  String _statutPaiement = 'En attente'; // Valeur par défaut
  int _currentPageIndex = 0;

  // Formatter pour les dates
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // Charger les impôts/taxes au démarrage
    final impotTaxeProvider = Provider.of<ImpotTaxeProvider>(
      context,
      listen: false,
    );
    impotTaxeProvider.getImpotsTaxes();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  // Fonction pour afficher le formulaire d'ajout/modification
  Future<void> _showFormDialog(
    BuildContext context, {
    ImpotTaxeModel? impotTaxe,
  }) async {
    if (impotTaxe != null) {
      // Si on modifie, on initialise les champs avec les valeurs existantes
      _nomController.text = impotTaxe.nom;
      _montantController.text = impotTaxe.montant.toString();
      _dateDeclaration = impotTaxe.dateDeclaration;
      _datePaiement = impotTaxe.datePaiement;
      _statutPaiement = impotTaxe.statutPaiement;
    } else {
      // Sinon, on réinitialise les champs
      _nomController.clear();
      _montantController.clear();
      _dateDeclaration = DateTime.now();
      _datePaiement = DateTime.now();
      _statutPaiement = 'En attente';
    }

    await showDialog(
      context: context,
      builder: (context) {
        final impotTaxeProvider = Provider.of<ImpotTaxeProvider>(
          context,
          listen: false,
        );
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                impotTaxe == null
                    ? 'Ajouter un Impôt/Taxe'
                    : 'Modifier un Impôt/Taxe',
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
                            return 'Veuillez entrer un nom';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _montantController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ), // Pour les nombres décimaux
                        decoration: const InputDecoration(labelText: 'Montant'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un montant';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Date Déclaration: ${_dateFormat.format(_dateDeclaration)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _dateDeclaration,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _dateDeclaration = selectedDate;
                            });
                          }
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Date Paiement: ${_dateFormat.format(_datePaiement)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _datePaiement,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _datePaiement = selectedDate;
                            });
                          }
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _statutPaiement,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            // Vérifiez que newValue n'est pas nul
                            setState(() {
                              _statutPaiement = newValue;
                            });
                          }
                        },
                        items:
                            <String>[
                              'En attente',
                              'Payé',
                              'En retard',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Statut Paiement',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner un statut';
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
                      final nom = _nomController.text;
                      final montant = double.parse(
                        _montantController.text,
                      ); // Convertir en double

                      if (impotTaxe == null) {
                        // Ajouter un nouvel impôt/taxe
                        final newImpotTaxe = ImpotTaxeModel(
                          id: DateTime.now().toString(),
                          nom: nom,
                          montant: montant,
                          dateDeclaration: _dateDeclaration,
                          datePaiement: _datePaiement,
                          statutPaiement: _statutPaiement,
                        );
                        await impotTaxeProvider.addImpotTaxe(newImpotTaxe);
                      } else {
                        // Modifier l'impôt/taxe existant
                        final updatedImpotTaxe = ImpotTaxeModel(
                          id: impotTaxe.id,
                          nom: nom,
                          montant: montant,
                          dateDeclaration: _dateDeclaration,
                          datePaiement: _datePaiement,
                          statutPaiement: _statutPaiement,
                        );
                        await impotTaxeProvider.updateImpotTaxe(
                          updatedImpotTaxe,
                        );
                      }
                      Navigator.of(context).pop();
                      // Afficher un message de succès
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            impotTaxe == null
                                ? 'Impôt/Taxe ajouté avec succès'
                                : 'Impôt/Taxe modifié avec succès',
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

  // Fonction pour afficher la boîte de dialogue de confirmation de suppression
  Future<void> _showDeleteDialog(
    BuildContext context,
    ImpotTaxeModel impotTaxe,
  ) async {
    final impotTaxeProvider = Provider.of<ImpotTaxeProvider>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cet impôt/taxe ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await impotTaxeProvider.deleteImpotTaxe(impotTaxe.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Impôt/Taxe supprimé avec succès'),
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
    final impotTaxeProvider = Provider.of<ImpotTaxeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Impôts et Taxes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Liste des Impôts et Taxes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildList(
                impotTaxeProvider,
              ), // Méthode pour construire la liste
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showFormDialog(context),
              child: const Text('Ajouter un Impôt/Taxe'),
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
      ), // Assurez-vous que c'est correct
    );
  }

  // Méthode pour construire la liste des impôts/taxes
  Widget _buildList(ImpotTaxeProvider impotTaxeProvider) {
    if (impotTaxeProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (impotTaxeProvider.error != null) {
      return Center(
        child: Text(
          'Erreur: ${impotTaxeProvider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (impotTaxeProvider.impotsTaxes.isEmpty) {
      return const Center(child: Text('Aucun impôt/taxe trouvé.'));
    } else {
      return ListView.builder(
        itemCount: impotTaxeProvider.impotsTaxes.length,
        itemBuilder: (context, index) {
          final impotTaxe = impotTaxeProvider.impotsTaxes[index];
          return _buildListItem(context, impotTaxe);
        },
      );
    }
  }

  // Méthode pour construire chaque élément de la liste
  Widget _buildListItem(BuildContext context, ImpotTaxeModel impotTaxe) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  impotTaxe.nom,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Montant: ${impotTaxe.montant}'),
                Text(
                  'Date Déclaration: ${_dateFormat.format(impotTaxe.dateDeclaration)}',
                ),
                Text(
                  'Date Paiement: ${_dateFormat.format(impotTaxe.datePaiement)}',
                ),
                Text('Statut: ${impotTaxe.statutPaiement}'),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed:
                      () => _showFormDialog(context, impotTaxe: impotTaxe),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, impotTaxe),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
