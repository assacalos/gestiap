import 'package:flutter/material.dart';
import 'package:gestiap/features/comptable/data/models/facture_model.dart';
import 'package:intl/intl.dart';

class FactureDetailsPage extends StatelessWidget {
  final InvoiceModel invoice;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  FactureDetailsPage({Key? key, required this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la Facture'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Numéro de Facture: ${invoice.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Date de Facture: ${_dateFormat.format(invoice.dateCreation)}',
                ),
                const SizedBox(height: 10),
                Text('Fournisseur: ${invoice.clientName}'),
                const SizedBox(height: 10),
                Text(
                  'Montant HT: ${invoice.totalHT.toStringAsFixed(2)}',
                ), // Affiche avec 2 décimales
                const SizedBox(height: 10),
                Text('Montant TVA: ${invoice.montantTVA.toStringAsFixed(2)}'),
                const SizedBox(height: 10),
                Text(
                  'Montant TTC: ${invoice.totalTTC.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Statut: ${invoice.status}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (invoice.commentaireRejet != null &&
                    invoice.commentaireRejet!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Commentaire de Rejet:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(invoice.commentaireRejet!),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
