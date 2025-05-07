import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:intl/intl.dart';

class ProformaDetailsPage extends StatelessWidget {
  final QuoteModel proforma;

  const ProformaDetailsPage({super.key, required this.proforma});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails du Devis #${proforma.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${proforma.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text('Client: ${proforma.clientName}'),
            Text(
              'Date de création: ${DateFormat('dd/MM/yyyy HH:mm').format(proforma.createdAt.toLocal())}',
            ),
            Text('Statut: ${proforma.status}'),
            const SizedBox(height: 15),
            const Text(
              'Articles:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (proforma.items.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: proforma.items.length,
                itemBuilder: (context, index) {
                  final item = proforma.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.description} (x${item.quantity})'),
                        Text(
                          '${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  );
                },
              )
            else
              const Text('Aucun article dans ce Proforma.'),
            const SizedBox(height: 15),
            Text('Remise: ${proforma.remise}%'),
            Text('Total HT: ${proforma.totalHT.toStringAsFixed(2)}'),
            Text(
              'Total TTC: ${proforma.totalTTC.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
