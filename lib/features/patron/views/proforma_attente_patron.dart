import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/views/providers/proforma_provider.dart';
import 'package:gestiap/features/commercial/views/pages/proforma_detail_page.dart';

class PendingProformaList extends StatelessWidget {
  const PendingProformaList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuoteProvider>(
      builder: (context, proformaProvider, child) {
        final pendingProformas =
            proformaProvider.quotes
                .where((q) => q.status == QuoteModel.statusPendingValidation)
                .toList();

        if (proformaProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (pendingProformas.isEmpty) {
          return const Center(
            child: Text('Aucun Proforma en attente de validation.'),
          );
        }

        return ListView.builder(
          itemCount: pendingProformas.length,
          itemBuilder: (context, index) {
            final proforma = pendingProformas[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  'Proforma #${proforma.id} - ${proforma.clientName}',
                ),
                subtitle: Text('Soumis le: ${proforma.createdAt.toLocal()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        Provider.of<QuoteProvider>(
                          context,
                          listen: false,
                        ).validateQuote(proforma.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        Provider.of<QuoteProvider>(
                          context,
                          listen: false,
                        ).rejectQuote(proforma.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProformaDetailsPage(proforma: proforma),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
