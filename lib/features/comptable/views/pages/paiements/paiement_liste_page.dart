import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/data/models/paiement_model.dart';
import 'package:gestiap/features/comptable/providers/paiement_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PaymentListScreen extends StatelessWidget {
  final String employeId;

  const PaymentListScreen({Key? key, required this.employeId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des Paiements')),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, _) {
          if (paymentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (paymentProvider.errorMessage != null) {
            return Center(
              child: Text('Erreur: ${paymentProvider.errorMessage}'),
            );
          } else if (paymentProvider.payments.isEmpty) {
            return const Center(
              child: Text('Aucun paiement enregistré pour cette charge.'),
            );
          } else {
            return ListView.builder(
              itemCount: paymentProvider.payments.length,
              itemBuilder: (context, index) {
                final PaymentModel payment = paymentProvider.payments[index];
                final formattedDate = DateFormat(
                  'dd/MM/yyyy HH:mm',
                ).format(payment.paymentDate);
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Montant: ${payment.amount}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: $formattedDate'),
                        Text('Méthode: ${payment.paymentMethod}'),
                        Text('Statut: ${payment.status}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditPaymentDialog(context, payment);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteConfirmationDialog(
                              context,
                              payment.id!,
                              employeId,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddPaymentDialog(context, employeId);
        },
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context, String chargeId) {
    final _formKey = GlobalKey<FormState>();
    double amount = 0.0;
    String paymentMethod = '';
    DateTime paymentDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un Paiement'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Montant'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le montant.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide.';
                    }
                    return null;
                  },
                  onSaved: (value) => amount = double.parse(value!),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Méthode de Paiement',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer la méthode de paiement.';
                    }
                    return null;
                  },
                  onSaved: (value) => paymentMethod = value!,
                ),
                // Ajoutez ici un sélecteur de date si nécessaire
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newPayment = PaymentModel(
                    id: '', // ID sera généré par le service
                    employeId: employeId,
                    paymentDate: paymentDate,
                    amount: amount,
                    paymentMethod: paymentMethod,
                    status: 'Réussi', // Statut par défaut lors de l'ajout
                  );
                  Provider.of<PaymentProvider>(
                    context,
                    listen: false,
                  ).addPayment(newPayment);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPaymentDialog(BuildContext context, PaymentModel payment) {
    final _formKey = GlobalKey<FormState>();
    double amount = payment.amount;
    String paymentMethod = payment.paymentMethod;
    DateTime paymentDate = payment.paymentDate;
    String status = payment.status;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier le Paiement'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: payment.amount.toString(),
                  decoration: const InputDecoration(labelText: 'Montant'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le montant.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide.';
                    }
                    return null;
                  },
                  onSaved: (value) => amount = double.parse(value!),
                ),
                TextFormField(
                  initialValue: payment.paymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Méthode de Paiement',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer la méthode de paiement.';
                    }
                    return null;
                  },
                  onSaved: (value) => paymentMethod = value!,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Statut'),
                  value: status,
                  items:
                      <String>['En attente', 'Réussi', 'Échoué'].map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    status = newValue!;
                  },
                ),
                // Ajoutez ici un sélecteur de date si nécessaire
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final updatedPayment = payment.copyWith(
                    amount: amount,
                    paymentMethod: paymentMethod,
                    status: status,
                  );
                  Provider.of<PaymentProvider>(
                    context,
                    listen: false,
                  ).updatePayment(updatedPayment);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    String paymentId,
    String employeId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la Suppression'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce paiement ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<PaymentProvider>(
                  context,
                  listen: false,
                ).deletePayment(paymentId, employeId);
                Navigator.of(context).pop();
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
