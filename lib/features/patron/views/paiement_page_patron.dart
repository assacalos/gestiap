import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/data/models/paiement_model.dart';
import 'package:gestiap/features/comptable/providers/paiement_provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/core/widgets/widgets_widgets.dart'; //Pour les CustomBottomNavigationBar

class PaiementPage extends StatefulWidget {
  const PaiementPage({Key? key}) : super(key: key);

  @override
  _PaiementPageState createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage> {
  int _currentPageIndex = 0; // Pour gérer l'index de la page actuelle
  String paymentId =
      ''; // ID du paiement à afficher, à définir selon votre logique
  // Pas besoin d'un ChangeNotifierProvider ici, il doit être au-dessus dans l'arbre des widgets
  @override
  void initState() {
    super.initState();
    // La logique d'initialisation du provider doit être dans le main.dart ou un parent
    final paiementProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );
    paiementProvider.getPayment(
      paymentId,
    ); // Charger les paiements au démarrage de la page.
  }

  @override
  Widget build(BuildContext context) {
    // Consolider l'accès au PaiementProvider
    final paiementProvider = Provider.of<PaymentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Paiements'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Utilisation d'une Column pour organiser les éléments de la page
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Liste des Paiements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Affichage de la liste des paiements
            Expanded(
              // Utilisation de Expanded pour que la ListView occupe l'espace restant
              child: _buildPaiementList(paiementProvider),
            ),
            const SizedBox(height: 20),
            //Bouton d'ajout de paiement
            ElevatedButton(
              onPressed: () {
                _showAddPaiementDialog(context, paiementProvider);
              },
              child: const Text('Ajouter un paiement'),
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

  // Méthode pour construire la liste des paiements
  Widget _buildPaiementList(PaymentProvider paiementProvider) {
    if (paiementProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Afficher un loader pendant le chargement
    } else if (paiementProvider.payments.isEmpty) {
      return const Center(
        child: Text('Aucun paiement trouvé.'),
      ); // Message si la liste est vide.
    } else {
      return ListView.builder(
        itemCount: paiementProvider.payments.length,
        itemBuilder: (context, index) {
          final PaymentModel paiement = paiementProvider.payments[index];
          return _buildPaiementListItem(paiement, paiementProvider);
        },
      );
    }
  }

  // Méthode pour construire chaque élément de la liste
  Widget _buildPaiementListItem(
    PaymentModel paiement,
    PaymentProvider paiementProvider,
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
                  'ID Paiement: ${paiement.id}', // ou toute autre info pertinente
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Montant: ${paiement.amount}'),
                Text('Date: ${paiement.paymentDate}'),
                Text('Type: ${paiement.paymentMethod}'),
                Text(
                  'Employé ID: ${paiement.employeId}',
                ), //Ajout du champ employeId
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditPaiementDialog(
                      context,
                      paiementProvider.payments, //Passer la liste
                      paiement,
                      paiementProvider,
                    ); // Passer le paiement à éditer
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeletePaiementDialog(
                      context,
                      paiement.id,
                      paiementProvider,
                    ); // Passer l'ID du paiement à supprimer
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour afficher la boîte de dialogue d'ajout de paiement
  void _showAddPaiementDialog(
    BuildContext context,
    PaymentProvider paiementProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    double montant = 0.0;
    DateTime date = DateTime.now();
    String type = '';
    String employeId = ''; // Champ pour l'ID de l'employé

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un paiement'),
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
                  // Utilisation de statefulBuilder pour mettre à jour l'affichage de la date
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
                      labelText: 'Type de paiement',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un type de paiement';
                      }
                      return null;
                    },
                    onSaved: (value) => type = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'ID Employé'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un ID Employé';
                      }
                      return null;
                    },
                    onSaved: (value) => employeId = value!,
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
                  final newPaiement = PaymentModel(
                    id: DateTime.now().toString(), // Générer un ID unique
                    employeId: employeId, // Utiliser la valeur entrée
                    amount: montant,
                    paymentDate: date,
                    paymentMethod: type,
                    status: 'En attente', // Statut par défaut
                    transactionId: null, // Ou une valeur par défaut
                  );
                  paiementProvider.addPayment(
                    newPaiement,
                  ); // Utiliser la méthode du provider
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Paiement ajouté avec succès!'),
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

  // Méthode pour afficher la boîte de dialogue de modification de paiement
  void _showEditPaiementDialog(
    BuildContext context,
    List<PaymentModel> paiements,
    PaymentModel paiementAModifier,
    PaymentProvider paiementProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    double montant = paiementAModifier.amount;
    DateTime date = paiementAModifier.paymentDate;
    String type = paiementAModifier.paymentMethod;
    String employeId = paiementAModifier.employeId; //Récupérer l'ID

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier un paiement'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: paiementAModifier.amount.toString(),
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
                    initialValue: paiementAModifier.paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Type de paiement',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un type de paiement';
                      }
                      return null;
                    },
                    onSaved: (value) => type = value!,
                  ),
                  TextFormField(
                    initialValue: paiementAModifier.employeId,
                    decoration: const InputDecoration(labelText: 'ID Employé'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un ID Employé';
                      }
                      return null;
                    },
                    onSaved: (value) => employeId = value!,
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
                  // Mettre à jour le paiement
                  final updatedPaiement = PaymentModel(
                    id: paiementAModifier.id, // Garder le même ID
                    amount: montant,
                    paymentDate: date,
                    paymentMethod: type,
                    employeId: employeId,
                    status: paiementAModifier.status, // Garder le même statut
                    transactionId: paiementAModifier.transactionId,
                  );
                  paiementProvider.updatePayment(
                    updatedPaiement,
                  ); // Utiliser la méthode update du provider

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Paiement modifié avec succès!'),
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
  void _showDeletePaiementDialog(
    BuildContext context,
    String paiementId,
    PaymentProvider paiementProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer un paiement'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce paiement ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                paiementProvider.deletePayment(
                  paiementId,
                  paiementProvider.payments
                      .firstWhere((p) => p.id == paiementId)
                      .employeId,
                ); // Utiliser la méthode delete du provider
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paiement supprimé avec succès!'),
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
