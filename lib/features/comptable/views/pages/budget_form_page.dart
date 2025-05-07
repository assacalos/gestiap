import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/data/models/budget_model.dart';
import 'package:gestiap/features/comptable/providers/budget.provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class BudgetFormPage extends StatefulWidget {
  final BudgetModel? budgetToEdit;
  const BudgetFormPage({super.key, this.budgetToEdit});

  @override
  _BudgetFormPageState createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nomController = TextEditingController();
  TextEditingController _dateDebutController = TextEditingController();
  TextEditingController _dateFinController = TextEditingController();
  Map<String, TextEditingController> _categoryControllers = {};
  List<String> _categoriesList = [];

  @override
  void initState() {
    super.initState();
    if (widget.budgetToEdit != null) {
      _nomController.text = widget.budgetToEdit!.nom;
      _dateDebutController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.budgetToEdit!.dateDebut);
      _dateFinController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.budgetToEdit!.dateFin);
      _categoriesList = widget.budgetToEdit!.categories.keys.toList();
      widget.budgetToEdit!.categories.forEach((key, value) {
        _categoryControllers[key] = TextEditingController(
          text: value.toStringAsFixed(2),
        );
      });
    } else {
      _dateDebutController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now());
      _dateFinController.text = DateFormat('yyyy-MM-dd').format(
        DateTime.now().add(const Duration(days: 30)),
      ); // Par défaut, un mois
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _addCategoryField() {
    setState(() {
      final newCategory = 'Nouvelle Catégorie ${_categoriesList.length + 1}';
      _categoriesList.add(newCategory);
      _categoryControllers[newCategory] = TextEditingController(text: '0.00');
    });
  }

  void _removeCategoryField(String category) {
    setState(() {
      _categoriesList.remove(category);
      _categoryControllers.remove(category);
    });
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      final budget = BudgetModel(
        id: widget.budgetToEdit?.id,
        nom: _nomController.text,
        dateDebut: DateTime.parse(_dateDebutController.text),
        dateFin: DateTime.parse(_dateFinController.text),
        categories: _categoryControllers.map(
          (key, value) => MapEntry(key, double.tryParse(value.text) ?? 0.0),
        ),
      );
      final budgetProvider = Provider.of<BudgetProvider>(
        context,
        listen: false,
      );
      if (widget.budgetToEdit == null) {
        budgetProvider.addBudget(budget);
      } else {
        budgetProvider.updateBudget(budget);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.budgetToEdit == null
              ? 'Créer un Budget'
              : 'Modifier le Budget',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom du Budget'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Champ obligatoire'
                            : null,
              ),
              TextFormField(
                controller: _dateDebutController,
                decoration: const InputDecoration(labelText: 'Date de Début'),
                readOnly: true,
                onTap: () => _selectDate(context, _dateDebutController),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Champ obligatoire'
                            : null,
              ),
              TextFormField(
                controller: _dateFinController,
                decoration: const InputDecoration(labelText: 'Date de Fin'),
                readOnly: true,
                onTap: () => _selectDate(context, _dateFinController),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Champ obligatoire'
                            : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Catégories de Budget:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._categoriesList.map((category) {
                return Row(
                  children: [
                    Expanded(child: Text(category)),
                    Expanded(
                      child: TextFormField(
                        controller: _categoryControllers[category],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Montant'),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Champ obligatoire';
                          if (double.tryParse(value) == null)
                            return 'Entrez un nombre valide';
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _removeCategoryField(category),
                    ),
                  ],
                );
              }).toList(),
              TextButton.icon(
                onPressed: _addCategoryField,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une Catégorie'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveBudget,
                child: const Text('Enregistrer le Budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
