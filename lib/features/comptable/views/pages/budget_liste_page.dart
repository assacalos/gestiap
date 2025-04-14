import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/views/pages/budget_form_page.dart';
import 'package:gestiap/features/comptable/views/providers/budget.provider.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/comptable/data/models/budget_model.dart';
import 'package:intl/intl.dart';

class BudgetsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Budgets')),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          if (budgetProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (budgetProvider.budgets.isEmpty) {
            return const Center(child: Text('Aucun budget disponible.'));
          }
          return ListView.builder(
            itemCount: budgetProvider.budgets.length,
            itemBuilder: (context, index) {
              final budget = budgetProvider.budgets[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.nom,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Période: ${DateFormat('dd/MM/yyyy').format(budget.dateDebut)} - ${DateFormat('dd/MM/yyyy').format(budget.dateFin)}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Catégories:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...budget.categories.entries.map(
                        (entry) => Text(
                          '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          BudgetFormPage(budgetToEdit: budget),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              _deleteBudget(context, budget.id!);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BudgetFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteBudget(BuildContext context, String budgetId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce budget ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<BudgetProvider>(
                  context,
                  listen: false,
                ).deleteBudget(budgetId);
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
