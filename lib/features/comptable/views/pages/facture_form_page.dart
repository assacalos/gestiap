import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/data/models/facture_model.dart';
import 'package:gestiap/features/comptable/views/providers/facture_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class InvoiceFormPage extends StatefulWidget {
  final InvoiceModel? invoiceToEdit;
  const InvoiceFormPage({super.key, this.invoiceToEdit});

  @override
  _InvoiceFormPageState createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _clientIdController = TextEditingController();
  TextEditingController _clientNameController = TextEditingController();
  TextEditingController _dateCreationController = TextEditingController();
  TextEditingController _dateEcheanceController = TextEditingController();
  List<InvoiceItem> _items = [];
  TextEditingController _newDescriptionController = TextEditingController();
  TextEditingController _newUnitPriceController = TextEditingController();
  TextEditingController _newQuantityController = TextEditingController();
  TextEditingController _referenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.invoiceToEdit != null) {
      _clientIdController.text = widget.invoiceToEdit!.clientId;
      _clientNameController.text = widget.invoiceToEdit!.clientName;
      _dateCreationController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.invoiceToEdit!.dateCreation);
      if (widget.invoiceToEdit!.dateEcheance != null) {
        _dateEcheanceController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(widget.invoiceToEdit!.dateEcheance!);
      }
      _items = [...widget.invoiceToEdit!.items];
      _referenceController.text = widget.invoiceToEdit!.reference ?? '';
    } else {
      _dateCreationController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now());
    }
  }

  double get _totalHT =>
      _items.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
  double get _totalTTC =>
      _totalHT; // Vous pouvez ajouter la logique de la TVA ici si nécessaire

  void _addItem() {
    if (_newDescriptionController.text.isNotEmpty &&
        _newUnitPriceController.text.isNotEmpty &&
        _newQuantityController.text.isNotEmpty) {
      setState(() {
        _items.add(
          InvoiceItem(
            description: _newDescriptionController.text,
            unitPrice: double.parse(_newUnitPriceController.text),
            quantity: int.parse(_newQuantityController.text),
          ),
        );
        _newDescriptionController.clear();
        _newUnitPriceController.clear();
        _newQuantityController.clear();
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _saveInvoice() {
    if (_formKey.currentState!.validate()) {
      final invoice = InvoiceModel(
        id: widget.invoiceToEdit?.id,
        clientId: _clientIdController.text,
        clientName: _clientNameController.text,
        dateCreation: DateTime.parse(_dateCreationController.text),
        dateEcheance:
            _dateEcheanceController.text.isNotEmpty
                ? DateTime.parse(_dateEcheanceController.text)
                : null,
        items: _items,
        totalHT: _totalHT,
        totalTTC: _totalTTC,
        status: widget.invoiceToEdit?.status ?? InvoiceModel.statusBrouillon,
        reference:
            _referenceController.text.isNotEmpty
                ? _referenceController.text
                : null,
      );
      final invoiceProvider = Provider.of<InvoiceProvider>(
        context,
        listen: false,
      );
      if (widget.invoiceToEdit == null) {
        invoiceProvider.addInvoice(invoice);
      } else {
        invoiceProvider.updateInvoice(invoice);
      }
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.invoiceToEdit == null
              ? 'Créer une Facture'
              : 'Modifier la Facture',
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
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Référence (Optionnel)',
                ),
              ),
              TextFormField(
                controller: _clientIdController,
                decoration: const InputDecoration(labelText: 'ID Client'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Champ obligatoire'
                            : null,
              ),
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(labelText: 'Nom du Client'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Champ obligatoire'
                            : null,
              ),
              TextFormField(
                controller: _dateCreationController,
                decoration: const InputDecoration(
                  labelText: 'Date de Création',
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _dateCreationController),
              ),
              TextFormField(
                controller: _dateEcheanceController,
                decoration: const InputDecoration(
                  labelText: 'Date d\'Échéance (Optionnel)',
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _dateEcheanceController),
              ),
              const SizedBox(height: 20),
              const Text(
                'Articles:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Row(
                  children: [
                    Expanded(child: Text(item.description)),
                    Expanded(
                      child: Text(
                        '${item.unitPrice.toStringAsFixed(2)} x ${item.quantity}',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _removeItem(index),
                    ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _newDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _newUnitPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix Unitaire',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _newQuantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantité'),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.add), onPressed: _addItem),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Text('Total HT: ${_totalHT.toStringAsFixed(2)}')],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Text('Total TTC: ${_totalTTC.toStringAsFixed(2)}')],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveInvoice,
                child: const Text('Enregistrer la Facture'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
