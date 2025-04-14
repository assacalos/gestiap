import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/comptable/views/providers/facture_provider.dart';
import 'package:gestiap/features/comptable/data/models/facture_model.dart';
import 'package:gestiap/features/comptable/views/pages/facture_form_page.dart';
import 'package:gestiap/features/comptable/utils/facture_pdf_generator.dart';

class FacturesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Factures')),
      body: Consumer<InvoiceProvider>(
        builder: (context, invoiceProvider, child) {
          if (invoiceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (invoiceProvider.invoices.isEmpty) {
            return const Center(child: Text('Aucune facture disponible.'));
          }
          return ListView.builder(
            itemCount: invoiceProvider.invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoiceProvider.invoices[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Facture #${invoice.reference ?? invoice.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Client: ${invoice.clientName}'),
                      Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(invoice.dateCreation)}',
                      ),
                      Text('Total TTC: ${invoice.totalTTC.toStringAsFixed(2)}'),
                      Text('Statut: ${invoice.status}'),
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
                                      (context) => InvoiceFormPage(
                                        invoiceToEdit: invoice,
                                      ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              _deleteInvoice(context, invoice.id!);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.picture_as_pdf),
                            onPressed: () {
                              generateInvoicePdf(invoice);
                            },
                          ),
                          if (invoice.status == InvoiceModel.statusBrouillon)
                            ElevatedButton(
                              onPressed: () {
                                _submitInvoice(context, invoice.id!);
                              },
                              child: const Text('Soumettre'),
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
            MaterialPageRoute(builder: (context) => InvoiceFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteInvoice(BuildContext context, String invoiceId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette facture ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<InvoiceProvider>(
                  context,
                  listen: false,
                ).deleteInvoice(invoiceId);
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

  void _submitInvoice(BuildContext context, String invoiceId) {
    Provider.of<InvoiceProvider>(
      context,
      listen: false,
    ).submitInvoice(invoiceId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facture soumise pour validation.')),
    );
  }
}
