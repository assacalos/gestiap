import 'package:flutter/material.dart';
import 'package:gestiap/features/commercial/data/models/proforma_model.dart';
import 'package:gestiap/features/commercial/providers/proformas/proforma_provider.dart';
import 'package:provider/provider.dart';

class PendingQuotesList extends StatefulWidget {
  const PendingQuotesList({super.key});

  @override
  State<PendingQuotesList> createState() => _PendingQuotesListState();
}

class _PendingQuotesListState extends State<PendingQuotesList> {
  final TextEditingController _rejectionReasonController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
      await quoteProvider.loadAllQuotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quoteProvider = Provider.of<QuoteProvider>(context);
    final pendingQuotes =
        quoteProvider.quotes
            .where((q) => q.status == QuoteModel.statusPendingValidation)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Proformas en Attente"),
        backgroundColor: Colors.orange,
      ),
      body:
          pendingQuotes.isEmpty
              ? const Center(child: Text("Aucun proforma en attente."))
              : ListView.builder(
                itemCount: pendingQuotes.length,
                itemBuilder: (context, index) {
                  final quote = pendingQuotes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: ListTile(
                      title: Text("Devis #${quote.id} - ${quote.clientName}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date: ${quote.createdAt.toLocal()}"),
                          if (quote.commentaire != null &&
                              quote.commentaire!.isNotEmpty)
                            Text("Commentaire: ${quote.commentaire}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            onPressed: () => _validateQuote(quote),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _showRejectDialog(quote),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  void _validateQuote(QuoteModel quote) async {
    final provider = Provider.of<QuoteProvider>(context, listen: false);
    await provider.validateQuote(quote.id);
  }

  void _showRejectDialog(QuoteModel quote) {
    _rejectionReasonController.clear();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Rejeter Proforma"),
            content: TextField(
              controller: _rejectionReasonController,
              decoration: const InputDecoration(
                labelText: "Motif du rejet",
                hintText: "Entrez la raison du rejet...",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_rejectionReasonController.text.trim().isEmpty) return;
                  final provider = Provider.of<QuoteProvider>(
                    context,
                    listen: false,
                  );
                  await provider.rejectQuote(
                    quote.id,
                    _rejectionReasonController.text.trim(),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Rejeter"),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }
}
