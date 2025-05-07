import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/providers/charges_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/comptable/data/models/charge_model.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; //Pour les CustomBottomNavigationBar

class ChargePage extends StatefulWidget {
  const ChargePage({Key? key}) : super(key: key);

  @override
  _ChargePageState createState() => _ChargePageState();
}

class _ChargePageState extends State<ChargePage> {
  int _currentPageIndex = 0; // Indice de la page actuelle
  // Pas besoin d'un ChangeNotifierProvider ici, il doit être au-dessus dans l'arbre des widgets
  @override
  void initState() {
    super.initState();
    // La logique d'initialisation du provider doit être dans le main.dart ou un parent
    final chargeProvider = Provider.of<ChargesProvider>(context, listen: false);
    chargeProvider
        .loadCharges(); // Charger les charges au démarrage de la page.
  }

  @override
  Widget build(BuildContext context) {
    // Consolider l'accès au ChargeProvider
    final chargeProvider = Provider.of<ChargesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Charges'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Utilisation d'une Column pour organiser les éléments de la page
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Liste des Charges',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Affichage de la liste des charges
            Expanded(
              // Utilisation de Expanded pour que la ListView occupe l'espace restant
              child: _buildChargeList(chargeProvider),
            ),
            const SizedBox(height: 20),
            // Bouton d'ajout de charge
            ElevatedButton(
              onPressed: () {
                _showAddChargeDialog(context, chargeProvider);
              },
              child: const Text('Ajouter une charge'),
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

  // Méthode pour construire la liste des charges
  Widget _buildChargeList(ChargesProvider chargeProvider) {
    if (chargeProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Afficher un loader pendant le chargement
    } else if (chargeProvider.charges.isEmpty) {
      return const Center(
        child: Text('Aucune charge trouvée.'),
      ); // Message si la liste est vide.
    } else {
      return ListView.builder(
        itemCount: chargeProvider.charges.length,
        itemBuilder: (context, index) {
          final ChargesModel charge = chargeProvider.charges[index];
          return _buildChargeListItem(charge, chargeProvider);
        },
      );
    }
  }

  // Méthode pour construire chaque élément de la liste
  Widget _buildChargeListItem(
    ChargesModel charge,
    ChargesProvider chargeProvider,
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
                  'ID Charge: ${charge.id}', // ou toute autre info pertinente
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Montant: ${charge.montant}'),
                Text('Date: ${charge.date}'),
                Text('Type: ${charge.categorie}'),
                Text('Description: ${charge.description}'),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditChargeDialog(
                      context,
                      chargeProvider.charges, // Passer la liste
                      charge,
                      chargeProvider,
                    ); // Passer la charge à éditer
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteChargeDialog(
                      context,
                      charge.id,
                      chargeProvider,
                    ); // Passer l'ID de la charge à supprimer
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour afficher la boîte de dialogue d'ajout de charge
  void _showAddChargeDialog(
    BuildContext context,
    ChargesProvider chargeProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    double montant = 0.0;
    DateTime date = DateTime.now();
    String type = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une charge'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Montant'),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un montant';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Montant invalide';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Montant doit être supérieur à zéro';
                      }
                      return null;
                    },
                    onSaved: (value) => montant = double.parse(value!),
                  ),
                  // Utilisation de StatefulBuilder pour mettre à jour l'affichage de la date
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
                    decoration: const InputDecoration(
                      labelText: 'Type de charge',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un type de charge';
                      }
                      return null;
                    },
                    onSaved: (value) => type = value!,
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
                  final newCharge = ChargesModel(
                    id: DateTime.now().toString(), // Générer un ID unique
                    montant: montant,
                    date: date,
                    categorie: type,
                    description: description,
                  );
                  chargeProvider.addCharges(
                    newCharge,
                  ); // Utiliser la méthode du provider
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Charge ajoutée avec succès!'),
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

  // Méthode pour afficher la boîte de dialogue de modification de charge
  void _showEditChargeDialog(
    BuildContext context,
    List<ChargesModel> charges,
    ChargesModel chargeAModifier,
    ChargesProvider chargeProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    double montant = chargeAModifier.montant;
    DateTime date = chargeAModifier.date;
    String type = chargeAModifier.categorie;
    String description = chargeAModifier.description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier une charge'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: chargeAModifier.montant.toString(),
                    decoration: const InputDecoration(labelText: 'Montant'),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un montant';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Montant invalide';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Montant doit être supérieur à zéro';
                      }
                      return null;
                    },
                    onSaved: (value) => montant = double.parse(value!),
                  ),
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
                    initialValue: chargeAModifier.categorie,
                    decoration: const InputDecoration(
                      labelText: 'Type de charge',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un type de charge';
                      }
                      return null;
                    },
                    onSaved: (value) => type = value!,
                  ),
                  TextFormField(
                    initialValue: chargeAModifier.description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une description';
                      }
                      return null;
                    },
                    onSaved: (value) => description = value!,
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
                  // Mettre à jour la charge
                  final updatedCharge = ChargesModel(
                    id: chargeAModifier.id, // Garder le même ID
                    montant: montant,
                    date: date,
                    categorie: type,
                    description: description,
                  );
                  chargeProvider.updateCharge(
                    updatedCharge,
                  ); // Utiliser la méthode update du provider

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Charge modifiée avec succès!'),
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
  void _showDeleteChargeDialog(
    BuildContext context,
    String chargeId,
    ChargesProvider chargeProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer une charge'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette charge ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                chargeProvider.deleteCharge(
                  chargeId,
                ); // Utiliser la méthode delete du provider
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Charge supprimée avec succès!'),
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
